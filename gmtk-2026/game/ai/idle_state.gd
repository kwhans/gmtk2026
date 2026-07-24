extends LimboState

# Idle.  Just wait until the player wanders into view

@export var vision_range = 35.0
@export var vistion_check_time = 0.4

@onready var monster:Monster
var targetPlayer:Player = null
var timeSinceLastVisionCheck:float = 0.0
var skipFrames = 3

func _ready() -> void:
	monster = owner as Monster

func _enter() -> void:
	monster.setAppearance(Monster.MonsterAppearance.Idle)
	var targetNode = get_tree().get_first_node_in_group(&"Player")
	targetPlayer = targetNode as Player
	if is_instance_valid(targetPlayer):
		timeSinceLastVisionCheck = 0.0

func _update(delta: float) -> void:
	if !is_instance_valid(targetPlayer):
		var targetNode = get_tree().get_first_node_in_group(&"Player")
		targetPlayer = targetNode as Player
		if !is_instance_valid(targetPlayer):
			printerr("Can't find targetPlayer!")
			return
	
	var distanceToPlayer = (targetPlayer.global_position - monster.global_position).length()
	if distanceToPlayer < vision_range:	
		timeSinceLastVisionCheck += delta
		if timeSinceLastVisionCheck > vistion_check_time:
			timeSinceLastVisionCheck = 0.0
			var view_is_unobstructed = monster.check_los_clear(targetPlayer)
			if view_is_unobstructed:
					# raycast sees through walls on the first frame, for some reason
				if skipFrames > 0:
					skipFrames -= 1
					#print ("skipping frame...")
					return
				dispatch(EVENT_FINISHED)
				# print(self," trying to finish Idle State")
				pass

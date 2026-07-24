extends LimboState

@onready var monster:Monster
@export var speedMultiplier:float = 2.0
@export var timeToLosePlayer:float = 2.0

var targetPlayer:Player = null
var timeSinceLostPlayer:float = 0.0

func _ready() -> void:
	monster = owner as Monster

func _enter() -> void:
	var targetNode = get_tree().get_first_node_in_group(&"Player")
	targetPlayer = targetNode as Player
	monster.setAppearance(Monster.MonsterAppearance.Attacking)
	monster.speed *= speedMultiplier
	
func _update(delta: float) -> void:
	if !is_instance_valid(targetPlayer):
		var targetNode = get_tree().get_first_node_in_group(&"Player")
		targetPlayer = targetNode as Player
		if !is_instance_valid(targetPlayer):
			printerr("Can't find targetPlayer!")
			return
			
	# check for LOS to player
	var targetInLos = monster.check_los(targetPlayer)
	if targetInLos:
		var playerDirection = targetPlayer.global_position - monster.global_position
		monster.set_path_direction(playerDirection.normalized())
		timeSinceLostPlayer = 0.0
	else:
		timeSinceLostPlayer += delta
		if timeSinceLostPlayer > timeToLosePlayer:
			dispatch(EVENT_FINISHED)
		

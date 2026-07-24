extends LimboState

# Move - find path to player, check for distance and line of sight to start attacking

@onready var monster:Monster
@export var agression_range = 15.0
@export var pathUpdateTime = 2.0

var targetPlayer:Player = null
var timeSinceLastPathUpdate:float = 0.0

func _ready() -> void:
	monster = owner as Monster

func _enter() -> void:
	monster.setAppearance(Monster.MonsterAppearance.Idle)
	var targetNode = get_tree().get_first_node_in_group(&"Player")
	targetPlayer = targetNode as Player
	if is_instance_valid(targetPlayer):
		timeSinceLastPathUpdate = 0.0
		monster.update_path_target(targetPlayer)
	
func _update(delta: float) -> void:
	if !is_instance_valid(targetPlayer):
		var targetNode = get_tree().get_first_node_in_group(&"Player")
		targetPlayer = targetNode as Player
		if !is_instance_valid(targetPlayer):
			printerr("Can't find targetPlayer!")
			return
	
	timeSinceLastPathUpdate += delta
	if timeSinceLastPathUpdate > pathUpdateTime:
		timeSinceLastPathUpdate = 0.0
		monster.update_path_target(targetPlayer)
	
	# set movement direction
	var destination = monster.get_next_waypoint()
	var local_destination = destination - monster.global_position
	var direction = local_destination.normalized()
	monster.set_path_direction(direction)
	
	# check for LOS to player
	var targetInLos = monster.check_los_clear(targetPlayer)
	if targetInLos:
		# check for range to player
		var distanceToPlayer = (targetPlayer.global_position - monster.global_position).length()
		if distanceToPlayer < agression_range:
			dispatch(EVENT_FINISHED)

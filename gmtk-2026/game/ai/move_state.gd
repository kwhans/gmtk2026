extends LimboState

# Move - find path to player, check for distance and line of sight to start attacking

@onready var monster:Monster
@export var agression_range = 15.0

var targetPlayer:Player = null

func _ready() -> void:
	monster = owner as Monster

func _enter() -> void:
	monster.setAppearance(Monster.MonsterAppearance.Idle)
	var targetNode = get_tree().get_first_node_in_group(&"Player")
	targetPlayer = targetNode as Player
	
func _update(_delta: float) -> void:
	if !is_instance_valid(targetPlayer):
		var targetNode = get_tree().get_first_node_in_group(&"Player")
		targetPlayer = targetNode as Player
		if !is_instance_valid(targetPlayer):
			return
	
	# check for LOS to player
	var targetInLos = monster.check_los(targetPlayer)
	if targetInLos:
		# check for range to player
		var distanceToPlayer = (targetPlayer.global_position - monster.global_position).length()
		if distanceToPlayer < agression_range:
			dispatch(EVENT_FINISHED)

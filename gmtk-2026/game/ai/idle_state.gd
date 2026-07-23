extends LimboState

# Idle.  Just wait until we're told we're finished

@onready var monster:Monster

func _ready() -> void:
	monster = owner as Monster

func _enter() -> void:
	monster.setAppearance(Monster.MonsterAppearance.Idle)

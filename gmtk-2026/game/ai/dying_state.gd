extends LimboState

@onready var monster:Monster

var playerInRange = false

func _ready() -> void:
	monster = owner as Monster

func _enter() -> void:
	monster.setAppearance(Monster.MonsterAppearance.Dying)
	
func _update(_delta: float) -> void:
	if playerInRange:
		dispatch(EVENT_FINISHED)

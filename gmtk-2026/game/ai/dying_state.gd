extends LimboState

@onready var monster:Monster

@export var fadeTime:float = 2.0

func _ready() -> void:
	monster = owner as Monster

func _enter() -> void:
	SignalBus.torched_a_ghost.emit()
	monster.setAppearance(Monster.MonsterAppearance.Dying)
	monster.beginFadeOut(fadeTime)

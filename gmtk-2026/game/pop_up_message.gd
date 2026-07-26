extends Area3D
@onready var hud_root: Control = $hudRoot
@onready var hint_label: Label = $hudRoot/HintLabel

@export var hint_text:String = "Add hint here"

func _ready() -> void:
	hint_label.text = hint_text
	
func _on_body_entered(_body: Node3D) -> void:
	hud_root.visible = true

func _on_body_exited(_body: Node3D) -> void:
	hud_root.visible = false

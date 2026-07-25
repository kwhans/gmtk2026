extends Area3D
@onready var hud_root: Control = $hudRoot



func _on_body_entered(body: Node3D) -> void:
	hud_root.visible = true



func _on_body_exited(body: Node3D) -> void:
	hud_root.visible = false

extends Node3D


func _on_goal_area_body_entered(_body: Node3D) -> void:
	SignalBus.level_complete.emit()

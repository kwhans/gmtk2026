extends Label

func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		print("Retry clicked!")   
		SignalBus.retry_level.emit()

func _on_mouse_entered() -> void:
	self_modulate = Color(0.043, 0.86, 0.819, 1.0)


func _on_mouse_exited() -> void:
	self_modulate = Color.WHITE

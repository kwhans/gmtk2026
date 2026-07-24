extends Node3D

func _on_burn_area_body_entered(body: Node3D) -> void:
	if body.is_in_group(&"Torches"):
		start_burning()

func start_burning():
	print("the wall is on fire")
	$FirePfx.emitting = true
	$BurnTime.start()




func _on_burn_time_timeout() -> void:
		queue_free()

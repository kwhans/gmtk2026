extends Node3D

@onready var fire_pfx: GPUParticles3D = $FirePfx
@onready var burning_sound: AudioStreamPlayer3D = $BurningSound
@onready var burn_time: Timer = $BurnTime

func _on_burn_area_body_entered(body: Node3D) -> void:
	if body.is_in_group(&"Torches"):
		start_burning()

func start_burning():
	print("the wall is on fire")
	fire_pfx.emitting = true
	burning_sound.play()
	burn_time.start()

func _on_burn_time_timeout() -> void:
	$StaticBody3D.collision_layer = 0
	SignalBus.wall_removed.emit()
	queue_free()

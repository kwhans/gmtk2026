extends RigidBody3D
class_name Torch

func _ready() -> void:
	begin_burnout()

func enableCollisions() -> void:
	$CollisionShape3D.set_deferred("disabled", false)

func begin_burnout():
	$BurnoutTimer.start()

func _on_burnout_timer_timeout() -> void:
	$TorchStick/FireParticles.emitting = false
	$TorchStick/SmokeParticles.emitting = false
	SignalBus.torch_lost.emit()
	queue_free()

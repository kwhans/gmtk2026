extends RigidBody3D
class_name Torch

func enableCollisions() -> void:
	$CollisionShape3D.set_deferred("disabled", false)

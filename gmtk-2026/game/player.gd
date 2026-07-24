extends CharacterBody3D
class_name Player

const HORIZONTAL_SWAY_SPEED = 0.3
const VERTICAL_SWAY_SPEED = 0.2
const MAX_HORIZONTAL_DISTANCE = 0.05
const MAX_VERTICAL_DISTANCE = 0.05
const THROW_SPEED = 10.0

var motion_time = 0
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var speed = 5
var jump_speed = 5
var mouse_sensitivity = 0.002
var heldTorch : Torch

const torchScene := preload("res://game/Torch.tscn")

@export var player_pcam: PhantomCamera3D = null

func _ready():
	spawn_torch()

func _physics_process(delta):
	velocity.y += -gravity * delta
	var input = Input.get_vector("left", "right", "forward", "back")
	var movement_dir = transform.basis * Vector3(input.x, 0, input.y)
	velocity.x = movement_dir.x * speed
	velocity.z = movement_dir.z * speed
	
	move_and_slide()
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = jump_speed

	# update camera position
	#if is_instance_valid(player_pcam):
		#player_pcam.set_third_person_rotation(rotation)

	# torch sway
func _process(delta: float) -> void:
	motion_time += delta
	if is_instance_valid(heldTorch):
		var offset_x = sin(motion_time*HORIZONTAL_SWAY_SPEED*TAU)*MAX_HORIZONTAL_DISTANCE
		heldTorch.position.x = offset_x
		var offset_y = sin(motion_time*VERTICAL_SWAY_SPEED*TAU)*MAX_VERTICAL_DISTANCE
		heldTorch.position.y = offset_y
	
func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		$Head.rotation.x = clamp($Head.rotation.x + (-event.relative.y * mouse_sensitivity), -PI/2, PI/2)
		#print($Head.rotation.x)
	elif event is InputEventMouseButton:
		if event.pressed:
			throw_torch()

func throw_torch():
	if heldTorch == null:
		push_warning("Attempted to throw non existant torch")
		return
	heldTorch.top_level = true
	heldTorch.freeze = false
	
	if %TorchAimRay.is_colliding():
		print("Throwing with an aim point!")
		var targetPoint = %TorchAimRay.get_collision_point()
		var torch2TargetVec = targetPoint - heldTorch.global_position
		var throwVelocity = torch2TargetVec.normalized() * THROW_SPEED
		heldTorch.linear_velocity = throwVelocity
	else:
		print("Throwing without a target point.")
		heldTorch.linear_velocity = $Head.global_basis.z * -THROW_SPEED
	heldTorch.angular_velocity = $Head.global_basis.x * -10
	heldTorch.enableCollisions()
	heldTorch = null
	$TorchReloadTimer.start()


func _on_torch_reload_timer_timeout() -> void:
	spawn_torch()

func spawn_torch():
	if heldTorch != null:
		push_warning("Attempted to load torch when one was already held")
		return
	heldTorch = torchScene.instantiate()
	%TorchOffset.add_child(heldTorch)
	
	

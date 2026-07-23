extends CharacterBody3D
class_name Player

const horizontal_sway_speed = 0.125
const vertical_sway_speed = 0.025
const max_horizontal_distance = 0.5
const max_vertical_distance = 0.15

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
		var offset_x = sin(motion_time*horizontal_sway_speed*TAU)*max_horizontal_distance
		heldTorch.position.x = offset_x
		var offset_y = sin(motion_time*vertical_sway_speed*TAU)*max_vertical_distance
		heldTorch.position.y = offset_y
	
func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		$Head.rotation.x = clamp($Head.rotation.x + (-event.relative.y * mouse_sensitivity), -PI/2, PI/2)
		print($Head.rotation.x)
	elif event is InputEventMouseButton:
		if event.pressed:
			throw_torch()

func throw_torch():
	if heldTorch == null:
		push_warning("Attempted to throw non existant torch")
		return
	heldTorch.top_level = true
	heldTorch.freeze = false
	heldTorch.linear_velocity = $Head.global_basis.z * -10
	heldTorch.angular_velocity = $Head.global_basis.x * -10
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
	
	

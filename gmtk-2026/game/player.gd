extends CharacterBody3D

const horizontal_sway_speed = 0.125
const vertical_sway_speed = 0.025
const max_horizontal_distance = 0.5
const max_vertical_distance = 0.15
const added_vertical_distance = 0.6

var motion_time = 0
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var speed = 5
var jump_speed = 5
var mouse_sensitivity = 0.002
var heldTorch : Torch

@export var player_pcam: PhantomCamera3D = null

func _ready():
	#TODO - load the first torch dynamically and create a reloader
	heldTorch = $TorchOffset/Torch

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
	if is_instance_valid(player_pcam):
		player_pcam.set_third_person_rotation(rotation)

	# torch sway
func _process(delta: float) -> void:
	motion_time += delta
	var offset_x = sin(motion_time*horizontal_sway_speed*TAU)*max_horizontal_distance
	$TorchOffset.position.x = offset_x
	var offset_y = sin(motion_time*vertical_sway_speed*TAU)*max_vertical_distance
	$TorchOffset.position.y = offset_y + added_vertical_distance
	
func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
	elif event is InputEventMouseButton:
		if event.pressed:
			throw_torch()

func throw_torch():
	if heldTorch == null:
		push_warning("Attempted to throw non existant torch")
		return
	heldTorch.top_level = true
	heldTorch.freeze = false
	heldTorch.linear_velocity = transform.basis.z * -10
	heldTorch = null

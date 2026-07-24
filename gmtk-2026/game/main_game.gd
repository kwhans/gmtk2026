extends Node3D

@onready var sky_phantom_camera_3d: PhantomCamera3D = $SkyPhantomCamera3D
@onready var player_root: Player = $PlayerRoot
@onready var game_over_timer: Timer = $GameOverTimer

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	SignalBus.game_over.connect(on_game_over)
	
func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event is InputEventKey and event.keycode == KEY_ESCAPE:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func on_game_over():
	sky_phantom_camera_3d.position.x = player_root.position.x
	sky_phantom_camera_3d.position.z = player_root.position.y
	sky_phantom_camera_3d.up = -player_root.basis.z
	sky_phantom_camera_3d.priority = 10
	game_over_timer.start()


func _on_game_over_timer_timeout() -> void:
	# show game over menu
	pass # Replace with function body.

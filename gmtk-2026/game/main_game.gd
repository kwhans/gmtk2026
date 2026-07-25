extends Node3D

@onready var sky_phantom_camera_3d: PhantomCamera3D = $SkyPhantomCamera3D
@onready var player_root: Player = $PlayerRoot
@onready var game_over_timer: Timer = $GameOverTimer
@onready var game_over_screen: CanvasLayer = $GameOverScreen
@onready var level_stub: Node3D = $LevelStub
@onready var torch_count_label: Label = $HUD/MarginContainer/HBoxContainer/TorchCountLabel


var is_game_over: bool = false
var currentLevel: int = 1
var torches_remaining: int = 3

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	SignalBus.game_over.connect(on_game_over)
	SignalBus.retry_level.connect(on_retry_level)
	SignalBus.return_to_main_menu.connect(on_return_to_main_menu)
	SignalBus.load_torches.connect(on_load_torches)
	SignalBus.torch_thrown.connect(on_torch_thrown)
	loadLevel(GlobalGameState.starting_level)
	
func _unhandled_input(event):
	print("Encountered unhandled input")
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		print("Considering re-capturing mouse")
		if not is_game_over:
			print("Re-capturing mouse")
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event is InputEventKey and event.keycode == KEY_ESCAPE:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func on_game_over() -> void:
	if is_game_over:
		return
	is_game_over = true
	sky_phantom_camera_3d.up = -player_root.basis.z
	sky_phantom_camera_3d.priority = 10
	game_over_timer.start()

func _on_game_over_timer_timeout() -> void:
	# show game over menu
	game_over_screen.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	pass # Replace with function body.

func on_retry_level() -> void:
	print("Reload level")
	clear_all_torches()
	loadLevel(currentLevel)
	sky_phantom_camera_3d.priority = 0
	game_over_screen.visible = false
	is_game_over = false
	
func loadLevel(levelNum:int) -> void:
	var newLevelScene : Resource = null
	match levelNum:
		1:
			newLevelScene = load("res://levels/maze1.tscn")
		_:
			printerr("Unrecognized level: ", levelNum)
	if newLevelScene == null:
		return
		
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	currentLevel = levelNum
	
	# Remove current level
	var loadedLevels = level_stub.get_children()
	for level in loadedLevels:
		level.queue_free()
		
	# load the new level
	var newLevelInstance = newLevelScene.instantiate()
	level_stub.add_child(newLevelInstance)
	SignalBus.level_start.emit(currentLevel)
	
	# stick player at start
	var spawnPoints = get_tree().get_nodes_in_group(&"StartPosition")
	if spawnPoints.size() <= 0:
		player_root.position = Vector3.ZERO
	elif spawnPoints.size() == 1:
		player_root.global_position = spawnPoints[0].global_position
		player_root.global_rotation = spawnPoints[0].global_rotation
	else:
		var index = randi() % spawnPoints.size()
		player_root.global_position = spawnPoints[index].global_position
		player_root.global_rotation = spawnPoints[index].global_rotation
		
func clear_all_torches() -> void:
	var allTorches = get_tree().get_nodes_in_group(&"Torches")
	for torch in allTorches:
		torch.queue_free()

func on_return_to_main_menu() -> void:
	get_tree().change_scene_to_file("res://game/MainMenu.tscn")

func on_load_torches(torch_count:int) -> void:
	torches_remaining = torch_count
	torch_count_label.text = str(torches_remaining)
	player_root.out_of_torches = torches_remaining <= 0

func on_torch_thrown() -> void:
	torches_remaining = max(torches_remaining - 1, 0)
	torch_count_label.text = str(torches_remaining)
	player_root.out_of_torches = torches_remaining <= 0
	

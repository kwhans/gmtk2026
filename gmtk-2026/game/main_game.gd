extends Node3D

@onready var sky_phantom_camera_3d: PhantomCamera3D = $SkyPhantomCamera3D
@onready var player_root: Player = $PlayerRoot
@onready var game_over_timer: Timer = $GameOverTimer
@onready var game_over_screen: CanvasLayer = $GameOverScreen
@onready var level_complete_screen: CanvasLayer = $LevelCompleteScreen
@onready var level_stub: Node3D = $LevelStub
@onready var torch_count_label: Label = $HUD/MarginContainer/HBoxContainer/TorchCountLabel

@onready var regular_song_myst: AudioStreamPlayer = $RegularSongMyst
@onready var regular_song_red_moon: AudioStreamPlayer = $RegularSongRedMoon
@onready var regular_song_the_crypt: AudioStreamPlayer = $RegularSongTheCrypt
@onready var exciting_song_fear_me: AudioStreamPlayer = $ExcitingSongFearMe
@onready var regular_song_silence_is_dead: AudioStreamPlayer = $RegularSongSilenceIsDead

var currentSong:AudioStreamPlayer = null

var is_game_over: bool = false
var currentLevel: int = 1
var torches_remaining: int = 3

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	SignalBus.game_over.connect(on_game_over)
	SignalBus.level_complete.connect(on_level_complete)
	SignalBus.load__next_level.connect(on_load_next_level)
	SignalBus.retry_level.connect(on_retry_level)
	SignalBus.load_torches.connect(on_load_torches)
	SignalBus.torch_thrown.connect(on_torch_thrown)
	loadLevel(GlobalGameState.starting_level)
	
func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if not is_game_over:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event is InputEventKey and event.keycode == KEY_ESCAPE:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func on_game_over() -> void:
	if is_game_over:
		return
	is_game_over = true
	playSong(null)
	sky_phantom_camera_3d.up = -player_root.basis.z
	sky_phantom_camera_3d.priority = 10
	game_over_timer.start()

func _on_game_over_timer_timeout() -> void:
	# show game over menu
	game_over_screen.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func on_level_complete() -> void:
	playSong(null)
	fade_out_master_bus(2.0)
	is_game_over = true
	level_complete_screen.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
func on_load_next_level() -> void:
	level_complete_screen.visible = false
	clear_all_torches()
	currentLevel += 1
	loadLevel(currentLevel)
	is_game_over = false
	
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
		2:
			newLevelScene = load("res://levels/generator/seeded_maze.tscn")
		_:
			#printerr("Unrecognized level: ", levelNum)
			restore_master_bus()
			get_tree().change_scene_to_file("res://game/WinScreen.tscn")
			return
			
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if newLevelScene == null:
		return
		
	currentLevel = levelNum
	
	# Remove current level
	var loadedLevels = level_stub.get_children()
	for level in loadedLevels:
		level.queue_free()
		
	# load the new level
	var newLevelInstance = newLevelScene.instantiate()
	level_stub.add_child(newLevelInstance)
	SignalBus.level_start.emit(currentLevel)
	restore_master_bus(0.5)
	playSongNumber(randi()%4) # play a random regular song
	
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

func on_load_torches(torch_count:int) -> void:
	torches_remaining = torch_count
	notify_of_updated_torch_count()

func on_torch_thrown() -> void:
	var previousTorchCount = torches_remaining
	torches_remaining = max(torches_remaining - 1, 0)
	if previousTorchCount != torches_remaining:
		notify_of_updated_torch_count()
		
func notify_of_updated_torch_count() -> void:
	torch_count_label.text = str(torches_remaining)
	player_root.out_of_torches = torches_remaining <= 0
	if player_root.out_of_torches:
		playSong(exciting_song_fear_me)
		SignalBus.out_of_torches.emit()
	
func playSongNumber(songNumber:int)->void:
	match songNumber:
		0: 
			playSong(regular_song_myst)
		1:
			playSong(regular_song_red_moon)
		2:
			playSong(regular_song_the_crypt)
		3:
			playSong(regular_song_silence_is_dead)
		4:
			playSong(exciting_song_fear_me)
		_:
			printerr("No song associated with selected index")

func playSong(song:AudioStreamPlayer) -> void:
	if currentSong == song:
		return # don't mess with current song
	
	const VOLUME_DB_OFF:float = -80.0
	const VOLUME_DB_ON:float = -20.0
	
	if (currentSong != null) and currentSong.playing:
		print("Fading out song: ", str(currentSong.stream))
		var fadeOutTween = create_tween()	
		fadeOutTween.tween_property(currentSong, "volume_db", VOLUME_DB_OFF, 1.0)
		fadeOutTween.tween_callback(currentSong.stop)
		
	if song != null:
		print("Fading in song: ", str(song.stream))
		song.volume_db = VOLUME_DB_OFF # start from nothing to fade in
		var fadeInTween = create_tween()
		fadeInTween.tween_callback(song.play)
		fadeInTween.tween_property(song, "volume_db", VOLUME_DB_ON, 1.0)

	currentSong = song

func fade_out_master_bus(duration: float = 0.5):
	var bus_index = AudioServer.get_bus_index("Master")
	if bus_index == -1:
		return
		
	var current_db = AudioServer.get_bus_volume_db(bus_index)
	var tween = create_tween()
	tween.tween_method(
		func(v): AudioServer.set_bus_volume_db(bus_index, v),
		current_db,
		-80.0,
		duration
	)
	
	tween.tween_callback(func(): AudioServer.set_bus_volume_db(bus_index, -80.0))
	
func restore_master_bus(duration: float = 0.0) -> void:
	var bus_index = AudioServer.get_bus_index("Master")
	if bus_index == -1:
		return
		
	if duration == 0.0:
		AudioServer.set_bus_volume_db(bus_index, 0.0)
		return
		
	var current_db = AudioServer.get_bus_volume_db(bus_index)
	var tween = create_tween()
	tween.tween_method(
		func(v): AudioServer.set_bus_volume_db(bus_index, v),
		current_db,
		0.0,
		duration
	)
	
	tween.tween_callback(func(): AudioServer.set_bus_volume_db(bus_index, 0.0))
	

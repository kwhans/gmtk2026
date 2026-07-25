extends Control

func _ready() -> void:
	SignalBus.start_main_game.connect(on_start_main_game)
	
func on_start_main_game() -> void:
	GlobalGameState.starting_level = 1
	get_tree().change_scene_to_file("res://game/LoadingScreen.tscn")
	

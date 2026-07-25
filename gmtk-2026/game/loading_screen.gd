extends Control

const PATH_OF_SCENE_TO_LOAD = "res://game/MainGame.tscn"
@onready var progress_bar: ProgressBar = $VBoxContainer/ProgressBar

var progress : Array[float]

func _ready():
	ResourceLoader.load_threaded_request(PATH_OF_SCENE_TO_LOAD)
	
func _process(_delta):
	# Get the loading status and progress (0.0 to 1.0)
	var loading_status = ResourceLoader.load_threaded_get_status(PATH_OF_SCENE_TO_LOAD, progress)
	
	match loading_status:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			progress_bar.value = progress[0] * 100.0
		ResourceLoader.THREAD_LOAD_LOADED:
			# Loading complete, switch to the new scene
			var resource = ResourceLoader.load_threaded_get(PATH_OF_SCENE_TO_LOAD)
			get_tree().change_scene_to_packed(resource)
		ResourceLoader.THREAD_LOAD_FAILED:
			print("Failed to load scene")

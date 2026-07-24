extends NavigationRegion3D
class_name Maze

func _ready() -> void:
	SignalBus.wall_removed.connect(on_wall_removed)
	bake_finished.connect(on_bake_finished)
	
func on_wall_removed() -> void:
	print("starting re-bake")
	bake_navigation_mesh(true)

func on_bake_finished()->void:
	print("re-bake finished")

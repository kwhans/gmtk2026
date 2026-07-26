class_name SeededMaze
extends Maze

var wall_scene := preload("res://levels/wall.tscn")
var wall_burnable_scene := preload("res://levels/BurnableWall.tscn")
var monster_scene := preload("res://game/Monster.tscn")

var maze_size := 10

var wallWidth: float = 10

var numberOfMonsters: int = 10
var numberOfBurnableWalls: int = 5 # is actually only half the number since some will be vertical and some will be horizontal

var mazeSpaces: Array
var verticalWalls: Array
var horizontalWalls: Array

var rando : RandomNumberGenerator

func _ready() -> void:
	super._ready()
	generate_maze()

func generate_maze() -> void:
	rando = RandomNumberGenerator.new()
	rando.seed = GlobalGameState.levelSeed
	mazeSpaces = build2Darray(maze_size, maze_size)
	verticalWalls = build2Darray(maze_size + 1, maze_size)
	horizontalWalls = build2Darray(maze_size, maze_size + 1)
	buildOuterWalls()
	randomInnerWalls()
	%PlayerStartPosition.position.x = wallWidth * rando.randf_range(maze_size / (-2.0), maze_size / 2.0)
	%Goal.position.x = wallWidth * rando.randf_range(maze_size / (-2.0), maze_size / 2.0)
	for m in numberOfMonsters:
		var newMonster: Monster = monster_scene.instantiate()
		var monsterx = rando.randi_range(0, maze_size - 1)
		var monstery = rando.randi_range(0, maze_size - 3)
		newMonster.gavinVariant = m % 2 > 0
		newMonster.position = calculateTilePosition(monsterx, monstery) + (Vector3.UP * 1.5)
		add_child(newMonster)

func buildOuterWalls():
	# horizontal first
	for i in maze_size:
		addWallToScene(true, i, 0)
		addWallToScene(true, i, maze_size)
		addWallToScene(false, 0, i)
		addWallToScene(false, maze_size, i)
		
func randomInnerWalls():
	for i in round(pow(maze_size, 1.5)):
		addWallToScene(true, rando.randi_range(0, maze_size - 1), rando.randi_range(1, maze_size - 1), i < numberOfBurnableWalls)
		addWallToScene(false, rando.randi_range(0, maze_size - 1), rando.randi_range(1, maze_size - 1), i < numberOfBurnableWalls)

func addWallToScene(horizontal: bool, x, y, burnable: bool = false) -> Node3D:
	#check for if the space is taken
	if horizontal:
		if is_instance_valid(horizontalWalls[x][y]):
			push_warning("There's already a wall there")
			return null
	else:
		if y == 0 || y == maze_size - 1:
			if x != 0 && x != maze_size:
				push_warning("Skipping wall in disallowed area")
				return null
		if is_instance_valid(verticalWalls[x][y]):
			push_warning("There's already a wall there")
			return null
	var newWall: Node3D
	if burnable:
		newWall = wall_burnable_scene.instantiate()
	else:
		newWall = wall_scene.instantiate()
	newWall.position = calculateWallPosition(horizontal, x, y)
	if horizontal:
		horizontalWalls[x][y] = newWall
	else:
		newWall.rotate_y(PI / 2.0)
		verticalWalls[x][y] = newWall
	add_child(newWall)
	return newWall

func calculateWallPosition(horizontal: bool, x, y) -> Vector3:
	var wallx = (x - (maze_size / 2.0)) * wallWidth
	var wally = (y - (maze_size / 2.0)) * wallWidth
	if horizontal:
		wallx += wallWidth / 2
	else:
		wally += wallWidth / 2
	return Vector3(wallx, 0, wally)

func calculateTilePosition(x, y) -> Vector3:
	var tilex = (x - (maze_size / 2.0)) * wallWidth + (wallWidth / 2.0)
	var tiley = (y - (maze_size / 2.0)) * wallWidth + (wallWidth / 2.0)
	return Vector3(tilex, 0, tiley)

func build2Darray(x, y) -> Array:
	var array: Array = []
	for i in x:
		var subArray: Array = []
		subArray.resize(y)
		array.append(subArray)
	return array

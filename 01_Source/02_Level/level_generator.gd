extends Node

var levels: Dictionary[Vector2, Level] = {}

var level_scenes: Array[PackedScene] = [
	preload("res://01_Source/02_Level/level.tscn")
]

func _ready() -> void:
	generate_map(10)
	print(levels)


func generate_map(tile_num):
	levels[Vector2(0,0)] = setup_level()
	
	var empty_connections = {
		Vector2.UP : null
	}
	
	for i in tile_num:
		var new_pos = empty_connections.keys().pick_random()
		empty_connections.erase(new_pos)
		levels[new_pos] = setup_level()
		
		var connected_rooms = {}
		
		for dir in GameData.DIRECTIONS.keys():
			var adj = new_pos + dir
			if adj not in levels:
				empty_connections[adj] = null
			
			else:
				connected_rooms[adj] = dir
		
		for adj in connected_rooms:
			var dir = connected_rooms[adj]
			var dir_ind = GameData.DIRECTIONS[dir]
			var inv_dir_ind = GameData.DIRECTIONS[dir*-1]
			levels[new_pos].connections[dir_ind] = levels[adj]
			levels[adj].connections[inv_dir_ind] = levels[new_pos]

func setup_level() -> Level:
	var output: Level = level_scenes.pick_random().instantiate()
	return output

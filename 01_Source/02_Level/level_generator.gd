extends Node

var levels: Dictionary[Vector2, Level] = {}

var level_scenes: Array[PackedScene] = [
	preload("res://01_Source/02_Level/level.tscn")
]

func _ready() -> void:
	generate_map(10)
	for lvl in levels.keys():
		print(lvl)
		print(levels[lvl])
		print("-")
		for c in levels[lvl].connections:
			if not c:
				print("null")
			else:
				print(c.map_pos)
		print("\n")


func generate_map(tile_num):
	var start_level = setup_level(Vector2.ZERO)
	var second_level = setup_level(Vector2.UP)
	start_level.connections[GameData.DIRECTIONS[Vector2.UP]] = second_level
	second_level.connections[GameData.DIRECTIONS[Vector2.DOWN]] = start_level
	levels[Vector2.ZERO] = start_level
	levels[Vector2.UP] = second_level
	
	var empty_connections = {
		Vector2.UP + Vector2.RIGHT : null,
		Vector2.UP + Vector2.LEFT : null,
		Vector2.UP + Vector2.UP : null
	}
	
	for i in tile_num:
		var new_pos = empty_connections.keys().pick_random()
		empty_connections.erase(new_pos)
		levels[new_pos] = setup_level(new_pos)
		
		var connected_rooms = {}
		
		for dir in GameData.DIRECTIONS.keys():
			var adj = new_pos + dir
			if adj not in levels:
				empty_connections[adj] = null
			
			else:
				connected_rooms[adj] = dir
		
		var con_chance = 1.
		
		for t in len(connected_rooms):
			var adj = connected_rooms.keys().pick_random()
			var dir = connected_rooms[adj]
			if randf() <= con_chance and adj != Vector2.ZERO:
				var dir_ind = GameData.DIRECTIONS[dir]
				var inv_dir_ind = GameData.DIRECTIONS[dir*-1]
				levels[new_pos].connections[dir_ind] = levels[adj]
				levels[adj].connections[inv_dir_ind] = levels[new_pos]
			connected_rooms.erase(adj)
			con_chance /= 2.
	
	spawn_exit(len(empty_connections))

func spawn_exit(exit_num):
	var seen = {levels[Vector2.ZERO] : null}
	var queue = [levels[Vector2.UP]]
	var l = 10
	while l:
		if l:
			print(queue)
			l -= 1
		var next_queue = []
		var possible_ends = {}
		while queue:
			var cur_lvl = queue.pop_front()
			for dir in GameData.DIRECTIONS:
				if cur_lvl.position + dir in levels:
					var dir_lvl = cur_lvl.connections[GameData.DIRECTIONS[dir]]
					if dir_lvl and dir_lvl not in seen:
						next_queue.push_back(dir_lvl)
						seen[dir_lvl] = null
					else: continue
				
				else:
					exit_num -= 1
					if exit_num == 0:
						print(cur_lvl.position+dir)
						return
		queue = next_queue

func setup_level(pos) -> Level:
	var new_level: Level = level_scenes.pick_random().instantiate()
	new_level.map_pos = pos
	return new_level

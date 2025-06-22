extends Node

var levels: Dictionary[Vector2, Level] = {}

var level_scenes: Array[PackedScene] = [
	preload("res://01_Source/02_Level/level.tscn")
]

func _ready() -> void:
	while not await generate_map(100): continue
	$MapOverlay.generate_map(levels.values())

func generate_map(tile_num):
	var start_level = setup_level(Vector2.ZERO)
	start_level.is_start = true
	var second_level = setup_level(Vector2.UP)
	start_level.connections[GameData.DIRECTIONS[Vector2.UP]] = second_level
	second_level.connections[GameData.DIRECTIONS[Vector2.DOWN]] = start_level
	levels[Vector2.ZERO] = start_level
	levels[Vector2.UP] = second_level
	$MapOverlay.generate_map(levels.values())
	await get_tree().create_timer(0.05).timeout
	
	var empty_connections = {
		Vector2.UP + Vector2.RIGHT : null,
		Vector2.UP + Vector2.LEFT : null,
		Vector2.UP + Vector2.UP : null
	}
	
	for i in tile_num:
		var new_pos = empty_connections.keys().pick_random()
		empty_connections.erase(new_pos)
		levels[new_pos] = setup_level(new_pos)
		
		var connected_rooms = []
		
		for dir in GameData.DIRECTIONS:
			var adj = new_pos + dir
			if adj not in levels:
				empty_connections[adj] = null
			
			else:
				connected_rooms.push_back(dir)
		
		var con_chance = 1.
		var con_num = 0
		for t in len(connected_rooms):
			var dir = connected_rooms.pick_random()
			connected_rooms.erase(dir)
			if new_pos + dir == Vector2.ZERO: continue
			if randf() <= con_chance:
				con_num += 1
				connect_level(new_pos, dir)
			con_chance /= 2.
		if con_num == 0: return false
		
		$MapOverlay.generate_map(levels.values())
		await get_tree().create_timer(0.05).timeout
	
	spawn_exit()
	return true

func spawn_exit():
	var seen = {Vector2.ZERO : null}
	var queue = [levels[Vector2.UP]]
	var possible_ends = []
	while queue:
		var next_queue = []
		var new_ends = []
		while queue:
			var cur_lvl = queue.pop_front()
			for dir in GameData.DIRECTIONS:
				if cur_lvl.map_pos + dir in seen: continue
				if cur_lvl.map_pos + dir in levels:
					var dir_lvl = cur_lvl.connections[GameData.DIRECTIONS[dir]]
					if dir_lvl:
						next_queue.push_back(dir_lvl)
						seen[cur_lvl.map_pos + dir] = null
				
				else:
					new_ends.append([cur_lvl.map_pos, dir])
		
		queue = next_queue
		possible_ends.push_front(new_ends)
	
	while possible_ends:
		var cur_ends = possible_ends.pop_front()
		if cur_ends:
			var picked_end = cur_ends.pick_random()
			var end_pos = picked_end[0] + picked_end[1]
			var end = setup_level(end_pos)
			levels[end_pos] = end
			end.is_end = true
			connect_level(picked_end[0], picked_end[1])
			return

func connect_level(level_pos, dir):
	var dir_ind = GameData.DIRECTIONS[dir]
	var inv_dir_ind = GameData.DIRECTIONS[dir*-1]
	levels[level_pos].connections[dir_ind] = levels[level_pos+dir]
	levels[level_pos+dir].connections[inv_dir_ind] = levels[level_pos]

func setup_level(pos) -> Level:
	var new_level: Level = level_scenes.pick_random().instantiate()
	new_level.map_pos = pos
	return new_level

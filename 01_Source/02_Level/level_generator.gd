extends Node

var small_level_scenes: Array[PackedScene] = [
	preload("res://01_Source/02_Level/Levels/SmallLevels/level0.tscn"),
	preload("res://01_Source/02_Level/Levels/SmallLevels/level1.tscn"),
	preload("res://01_Source/02_Level/Levels/SmallLevels/level2.tscn"),
]

var small_medium_level_scenes: Array[PackedScene] = [
	preload("res://01_Source/02_Level/Levels/MediumSmallLevels/level0.tscn"),
	preload("res://01_Source/02_Level/Levels/MediumSmallLevels/level1.tscn"),
	preload("res://01_Source/02_Level/Levels/MediumSmallLevels/level2.tscn"),
]

var big_medium_level_scenes: Array[PackedScene] = [
	preload("res://01_Source/02_Level/Levels/MediumBigLevels/level0.tscn"),
	preload("res://01_Source/02_Level/Levels/MediumBigLevels/level1.tscn"),
	preload("res://01_Source/02_Level/Levels/MediumBigLevels/level2.tscn"),
]

var big_level_scenes: Array[PackedScene] = [
	preload("res://01_Source/02_Level/Levels/BigLevels/level0.tscn"),
	preload("res://01_Source/02_Level/Levels/BigLevels/level1.tscn"),
	preload("res://01_Source/02_Level/Levels/BigLevels/level2.tscn"),
]

var starting_level_scene = preload("res://01_Source/02_Level/Levels/starting_room.tscn")
var secret_level_scene = preload("res://01_Source/02_Level/Levels/starting_room.tscn")


var map: Dictionary[Vector2, MapNode] = {}

class MapNode:
	var map: Dictionary[Vector2, MapNode]
	var pos: Vector2
	var is_end: bool
	var cons: Array[bool] = [false, false, false, false]
	
	func _init(map: Dictionary[Vector2, MapNode], pos: Vector2) -> void:
		self.pos = pos
		self.map = map
	
	func connect_node(dir: Vector2):
		var target_node = map[self.pos + dir]
		self.cons[GameData.DIRECTIONS[dir]] = true
		target_node.cons[GameData.DIRECTIONS[dir*-1]] = true

func get_levels(node_num) -> Dictionary[Vector2, Level]:
	while not generate_map(node_num): continue
	
	var h = randf()
	var s = randf_range(0.1, 0.2)
	var v = randf_range(0.9, 1)
	
	var tint = Color.from_hsv(h,s,v)
	
	var levels: Dictionary[Vector2, Level] = {}
	for node: MapNode in map.values():
		var con_num = 0
		for c in node.cons:
			if c: con_num += 1
		
		var lvl_list: Array[PackedScene]
		match con_num:
			1: lvl_list = small_level_scenes
			2: lvl_list = small_medium_level_scenes
			3: lvl_list = big_medium_level_scenes
			4: lvl_list = big_level_scenes
		
		var new_level: Level
		if node.pos == Vector2.ZERO:
			new_level = starting_level_scene.instantiate()
		elif con_num == 4 and randf() < 0.01:
			new_level = secret_level_scene.instantiate()
		else:
			new_level = lvl_list.pick_random().instantiate()
		
		new_level.is_end = node.is_end
		new_level.map_pos = node.pos
		new_level.tint = tint
		levels[node.pos] = new_level
	
	for node: MapNode in map.values():
		var cur_lvl = levels[node.pos]
		for i in 4:
			if node.cons[i] and not cur_lvl.connections[i]:
				var other_lvl = levels[node.pos + GameData.INVERSE_DIRECTIONS[i]]
				var r = randi_range(0, 1)
				cur_lvl.connections[i] = 1 if r else 2
				other_lvl.connections[(i + 2) % 4] = 2 if r else 1
				r = randi_range(0, 1)
				if r:
					cur_lvl.connections[i] += 2
					other_lvl.connections[(i + 2) % 4] += 2
	
	return levels

func generate_map(tile_num):
	var start_node = MapNode.new(map, Vector2.ZERO)
	var second_level = MapNode.new(map, Vector2.UP)
	map[Vector2.ZERO] = start_node
	map[Vector2.UP] = second_level
	start_node.connect_node(Vector2.UP)
	
	var empty_connections = {
		Vector2.UP + Vector2.RIGHT : null,
		Vector2.UP + Vector2.LEFT : null,
		Vector2.UP + Vector2.UP : null
	}
	
	for i in tile_num:
		var new_pos = empty_connections.keys().pick_random()
		empty_connections.erase(new_pos)
		map[new_pos] = MapNode.new(map, new_pos)
		
		var connected_rooms = []
		
		for dir in GameData.DIRECTIONS:
			var adj = new_pos + dir
			if adj not in map:
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
				map[new_pos].connect_node(dir)
			con_chance *= 0.35
		if con_num == 0: return false
	
	return spawn_exit()

func spawn_exit():
	var seen = {Vector2.ZERO : null}
	var queue = [Vector2.UP]
	var possible_ends = []
	while queue:
		var next_queue = []
		var new_ends = []
		while queue:
			var cur_lvl = queue.pop_front()
			for dir in GameData.DIRECTIONS:
				var dir_pos = cur_lvl + dir
				if dir_pos in seen: continue
				if dir_pos in map:
					if map[cur_lvl].cons[GameData.DIRECTIONS[dir]]:
						next_queue.push_back(dir_pos)
						seen[dir_pos] = null
				
				else:
					new_ends.append([cur_lvl, dir])
		
		queue = next_queue
		possible_ends.push_front(new_ends)
	
	while possible_ends:
		var cur_ends = possible_ends.pop_front()
		if cur_ends:
			var picked_end = cur_ends.pick_random()
			var end_pos = picked_end[0] + picked_end[1]
			var end = MapNode.new(map, end_pos)
			end.is_end = true
			map[end_pos] = end
			map[picked_end[0]].connect_node(picked_end[1])
			return true
	
	return false

func connect_level(level_pos, dir):
	var dir_ind = GameData.DIRECTIONS[dir]
	var inv_dir_ind = GameData.DIRECTIONS[dir*-1]
	map[level_pos].connections[dir_ind] = map[level_pos+dir]
	map[level_pos+dir].connections[inv_dir_ind] = map[level_pos]

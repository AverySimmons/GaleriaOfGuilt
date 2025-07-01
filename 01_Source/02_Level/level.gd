class_name Level
extends Node2D

@onready var entities: Node2D = $Entities
@onready var camera: Camera2D = $Camera2D
@onready var blood_manager: BloodManager = $BloodManager
@onready var doors: Node2D = $Doors

var enemies_left = 0
var enemy_credits = 0

var enter_timer = 0.5

var top_left: Vector2
var bot_right: Vector2

signal item_picked_up()

var item

var entrance_door

var escape_timer = 0
var distance = 0

var mall_scaling: Array[float] = [
	2, 3, 4, 5, 6
]

var mall_flat: Array[float] = [
	5, 20, 25, 30, 35
]

var size_scaling: Array[float] = [
	1, 1.2, 1.4, 1.6
]

var enemy_spawn_scene = preload("res://01_Source/01_Combat/Enemies/EnemySpawn/enemy_spawn.tscn")
var item_scene = preload("res://01_Source/02_Level/Item/item.tscn")

var enemy_scenes = {
	preload("res://01_Source/01_Combat/Enemies/lizard.tscn") : 15.,
	preload("res://01_Source/01_Combat/Enemies/worm.tscn") : 10.,
	preload("res://01_Source/01_Combat/Enemies/locust.tscn") : 5.,
}

var item_sprites = [
	preload("res://00_Assets/00_Sprites/Objective_item_sprites/heart_shaped_sunglasses_sprite.png"),
	preload("res://00_Assets/00_Sprites/Objective_item_sprites/compact_mirror_sprite.png"),
	preload("res://00_Assets/00_Sprites/Objective_item_sprites/ring_sprite.png"),
	preload("res://00_Assets/00_Sprites/Objective_item_sprites/lamb_plush_sprite.png"),
	preload("res://00_Assets/00_Sprites/Objective_item_sprites/human_heart_sprite.png"),
]

var max_enemies_in_wave = 5
var enemy_spacing = 200
var enemy_player_spacing = 330

var arrow_scene = preload("res://03_Components/arrow_indicator.tscn")

# 0 is no connection
# 1 is up
# 2 is down
var connections: Array[int] = [0, 0, 0, 0]
var is_end: bool = false
var map_pos: Vector2 = Vector2.ZERO
var map_piece: MapPiece = null
var tint: Color = Color(0,0,0,0)

signal exited_room(dir: Vector2)

func _ready() -> void:
	$NavigationRegion2D.bake_navigation_polygon()
	
	if not GameData.is_escaping and not is_end:
		GameData.music_event.set_parameter("combat state", 1)
		for d in doors.get_children():
			d.lock()
	map_piece.visible = true
	var con_num = -1
	for c in connections: if c: con_num += 1
	
	enemy_credits = mall_flat[GameData.mall_ind] + \
		mall_scaling[GameData.mall_ind] * distance
	
	enemy_credits *= size_scaling[con_num]
	
	$MultiplyLayer.color = tint
	
	top_left = $TopLeft.global_position
	bot_right = $BottomRight.global_position
	camera.limit_left = top_left.x
	camera.limit_top = top_left.y
	camera.limit_right = bot_right.x
	camera.limit_bottom = bot_right.y
	
	# HEY IT"S Me JOEY
	if UpgradeData.upgrades_gained[UpgradeData.ENTER_ROOM]:
		GameData.player.gain_blood_other(30)
		GameData.player.dealt_damage_took_damage = true
	
	#var center = Vector3((top_left.x+bot_right.x) * 0.5, (top_left.y+bot_right.y) * 0.5, 0)
	#var size = Vector3(bot_right.x-top_left.x, bot_right.y-top_left.y, 0)
	#blood_manager.multimesh.custom_aabb = AABB(center, size)
	
	for d in doors.get_children():
		if d is EntranceDoor:
			entrance_door = d
			d.exit.connect(exit, ConnectFlags.CONNECT_DEFERRED)
			continue
		var con_value = connections[GameData.DIRECTIONS[d.direction]]
		if con_value:
			d.exit.connect(exit, ConnectFlags.CONNECT_DEFERRED)
			
			if con_value > 2:
				d.is_stair = true
				con_value -= 2
			
			if con_value == 2:
				d.is_top = true
			
			d.setup_sprite()
			
		else:
			d.queue_free()
	
	enemy_credits = int(enemy_credits)
	
	if is_end:
		spawn_item()
	else:
		populate_enemies()

func _process(delta: float) -> void:
	var t = create_tween()
	t.tween_property(camera, "global_position", GameData.player.global_position, 0.1)
	
	if enemies_left <= 0 and not GameData.is_escaping:
		GameData.music_event.set_parameter("combat state", 0)

func _physics_process(delta: float) -> void:
	enter_timer -= delta
	if not GameData.is_escaping: return
	var con_num = -1
	for c in connections: if c: con_num += 1
	enemy_credits = mall_flat[GameData.mall_ind] * 1.5
	enemy_credits *= size_scaling[con_num]
	enemy_credits = int(enemy_credits)
	escape_timer -= delta
	if escape_timer <= 0:
		escape_timer += 0.5
		populate_enemies()

func spawn_item():
	item = item_scene.instantiate()
	item.texture = item_sprites[GameData.mall_ind]
	item.found.connect(item_interact)
	item.global_position = Vector2.ZERO
	entities.add_child(item)

func populate_enemies():
	# max number of enemies in a wave
	# distance between enemies
	# distance between enemies and the player
	
	# get a list of enemies
	# while there is enemies left in the list
	# generate a list of spawn points
	# spawn enemies at them
	# wait for a bit
	# repeat
	
	var enemy_list = get_enemy_list()
	enemies_left = len(enemy_list)
	while enemy_list:
		var spawns = get_spawn_point_list()
		
		var scored_spawns = score_spawn_list(spawns)
		var total_score = 0
		for i in scored_spawns.values(): total_score += i
		
		var enemy_num = min(len(scored_spawns), len(enemy_list), max_enemies_in_wave)
		
		for i in enemy_num:
			var cur_enemy = enemy_list.pick_random()
			enemy_list.erase(cur_enemy)
			
			var r = randf() * total_score
			var c = 0.
			var cur_spawn
			for s in scored_spawns.keys():
				var score = scored_spawns[s]
				c += score
				
				if c >= r:
					cur_spawn = s
					total_score -= score
					break
			scored_spawns.erase(cur_spawn)
			
			spawn_enemy(cur_spawn, cur_enemy)
		
		await get_tree().create_timer(5, false).timeout

func score_spawn_list(spawns: Array[Vector2]) -> Dictionary[Vector2, float]:
	var new_list: Dictionary[Vector2, float] = {}
	
	var player_pos = GameData.player.global_position
	var average_dist: float = 0.
	
	for s in spawns:
		average_dist += s.distance_to(player_pos)
	
	average_dist /= float(spawns.size())
	
	for s in spawns:
		var player_dist = s.distance_to(player_pos)
		var score = 1. - player_dist / average_dist
		score = clampf(score, 0, 1)
		new_list[s] = score
	
	return new_list

func get_enemy_list() -> Array[PackedScene]:
	var list: Array[PackedScene] = []
	
	var enemy_choices = enemy_scenes.duplicate()
	var cur_credits = enemy_credits
	
	while cur_credits >= 5:
		var total_cost = 0.
		for cost in enemy_choices.values(): total_cost += 1. / (cost * cost)
		var r = randf() * total_cost
		var c = 0.
		
		var enemy_chosen
		for key in enemy_choices.keys():
			var cost = 1. / enemy_choices[key]
			c += cost * cost
			if c >= r:
				enemy_chosen = key
				break
		
		
		if cur_credits < enemy_choices[enemy_chosen]:
			enemy_choices.erase(enemy_chosen)
			continue
		
		cur_credits -= enemy_choices[enemy_chosen]
		list.push_back(enemy_chosen)
	
	return list

func get_spawn_point_list() -> Array[Vector2]:
	var list: Array[Vector2] = []
	
	var space_state = get_world_2d().direct_space_state
	
	for i in 30:
		var rand_pos = Vector2(randf_range(top_left.x+100, bot_right.x-100), \
								randf_range(top_left.y+100, bot_right.y-100))
		
		if not check_enemy_spawn(rand_pos, list, space_state): continue
		
		list.push_back(rand_pos)
	
	return list

func check_enemy_spawn(pos: Vector2, spawns: Array[Vector2], \
		space_state: PhysicsDirectSpaceState2D) -> bool:
	var player_pos = GameData.player.global_position
	if pos.distance_to(player_pos) < enemy_player_spacing: return false
	
	for s in spawns:
		if pos.distance_to(s) < enemy_spacing: return false
	
	var circle = CircleShape2D.new()
	circle.radius = 200
	
	var params = PhysicsShapeQueryParameters2D.new()
	params.shape = circle
	params.transform = Transform2D(0, pos)
	params.collide_with_areas = false
	params.collide_with_bodies = true
	var collided = space_state.intersect_shape(params)
	
	return not collided

func spawn_enemy(pos: Vector2, ene: PackedScene) -> void:
	var new_enemy = ene.instantiate()
	new_enemy.bullet_node = entities
	new_enemy.indicator_node = $AttackIndicators
	new_enemy.level = self
	var new_enemy_spawn = enemy_spawn_scene.instantiate()
	new_enemy_spawn.entities_node = entities
	new_enemy_spawn.global_position = pos
	new_enemy_spawn.enemy = new_enemy
	new_enemy_spawn.spawn_time = 0.5 if GameData.is_escaping else 1
	entities.add_child(new_enemy_spawn)

func enemy_died(enemy) -> void:
	enemies_left -= 1
	if enemies_left <= 0:
		for d in doors.get_children():
			d.unlock()

func enter(dir: Vector2) -> void:
	SignalBus.death.connect(enemy_died)
	enter_timer = 0.5
	blood_manager.spawn()
	if dir == Vector2.ZERO:
		GameData.player.global_position = entrance_door.player_spawn.global_position
		camera.global_position = GameData.player.global_position
		entities.add_child(GameData.player)
		return
	
	for d: Door in doors.get_children():
		if d.direction == dir * -1:
			GameData.player.global_position = d.player_spawn.global_position
			entities.add_child(GameData.player)
			break
	
	camera.global_position = GameData.player.global_position

func exit(dir: Vector2):
	if enter_timer > 0: return
	if enemies_left > 0 and not GameData.is_escaping: return
	
	SignalBus.death.disconnect(enemy_died)
	
	entities.remove_child(GameData.player)
	
	if dir == Vector2.ZERO:
		if not GameData.is_escaping: return
		exited_room.emit(Vector2.ZERO)
		return
	
	if map_pos == Vector2.ZERO and dir == Vector2.DOWN:
		exited_room.emit(Vector2.ZERO)
	else:
		exited_room.emit(dir)

func item_interact():
	item_picked_up.emit()

func spawn_arrow(size: float, arrow_size: float, color: Color) -> ArrowIndicator:
	var new_arrow: ArrowIndicator = arrow_scene.instantiate()
	new_arrow.arrow_size = arrow_size
	new_arrow.color = color
	new_arrow.scale.y = size
	$AttackIndicators.add_child(new_arrow)
	return new_arrow

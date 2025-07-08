extends Node2D

@onready var entities: Node2D = $Entities
@onready var attack_indicators: Node2D = $AttackIndicators
@onready var blood_manager: BloodManager = $BloodManager
@onready var camera: Camera2D = $Camera2D

var arrow_scene = preload("res://03_Components/arrow_indicator.tscn")

var enemy_scenes = {
	preload("res://01_Source/01_Combat/Enemies/lizard.tscn") : 15.,
	preload("res://01_Source/01_Combat/Enemies/worm.tscn") : 10.,
	preload("res://01_Source/01_Combat/Enemies/locust.tscn") : 5.,
}

var upgraded_scenes = {
	"Locust" : preload("res://01_Source/01_Combat/Enemies/locust.tscn"),
	"Worm" : preload("res://01_Source/01_Combat/Enemies/worm.tscn"),
	"Lizard" : preload("res://01_Source/01_Combat/Enemies/lizard.tscn")
}

var enemy_spawn_scene = preload("res://01_Source/01_Combat/Enemies/EnemySpawn/enemy_spawn.tscn")

var max_enemies_in_wave = 10
var enemy_credits = 50
var level_radius = 720 - 100
var enemy_player_spacing = 200
var enemy_spacing = 100

var enemies_left = 0

var is_roaming = true
var roaming_timer = 15

signal boss_defeated()
var timer = 5

func _ready() -> void:
	GameData.player.global_position = $PlayerSpawn.global_position
	GameData.is_escaping = false
	entities.add_child(GameData.player)
	blood_manager.spawn()

func _process(delta: float) -> void:
	camera.global_position = GameData.player.global_position
	print(camera.global_position)

func _physics_process(delta: float) -> void:
	if is_roaming:
		
		
		roaming_timer -= delta
		if roaming_timer < 0:
			lock_level()
			spawn_boss()
			
			is_roaming = false
	
	

func spawn_boss() -> void:
	pass

func lock_level() -> void:
	GameData.boss_fight_offset = camera.global_position
	var top_left = $TopLeft.global_position + GameData.boss_fight_offset
	var bot_right = $BottomRight.global_position + GameData.boss_fight_offset
	camera.limit_left = top_left.x
	camera.limit_top = top_left.y
	camera.limit_right = bot_right.x
	camera.limit_bottom = bot_right.y
	
	SignalBus.death.connect(enemy_died)

func upgrade_enemy(enemy: Enemy) -> void:
	var new_enemy = upgraded_scenes[enemy.type]
	new_enemy.global_position = enemy.global_position
	enemy.queue_free()
	entities.add_child(new_enemy)

func enemy_died(enemy) -> void:
	enemies_left -= 1
	if enemies_left <= 0:
		## tell boss to drop
		pass

func phase1() -> void:
	pass

func phase2() -> void:
	pass

func phase3() -> void:
	pass

func populate_enemies() -> void:
	var enemy_list = get_enemy_list()
	enemies_left = len(enemy_list)
	await get_tree().create_timer(1, false).timeout
	while enemy_list:
		spawn_wave(enemy_list)
		if !is_inside_tree(): return
		await get_tree().create_timer(5, false).timeout

func spawn_wave(enemy_list):
	var spawns = get_spawn_point_list()
	
	var scored_spawns = score_spawn_list(spawns)
	
	var enemy_num = min(len(scored_spawns.keys()), len(enemy_list), max_enemies_in_wave)
	
	for i in enemy_num:
		var cur_enemy = enemy_list.pick_random()
		enemy_list.erase(cur_enemy)
		
		var total_score = 0
		for sc in scored_spawns.values(): total_score += sc
		
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
	

func score_spawn_list(spawns: Array[Vector2]) -> Dictionary[Vector2, float]:
	var new_list: Dictionary[Vector2, float] = {}
	
	var player_pos = GameData.player.global_position
	var max_dist: float = 0.
	
	for s in spawns:
		max_dist = max(max_dist, s.distance_to(player_pos))
	
	for s in spawns:
		var player_dist = s.distance_to(player_pos)
		var score = 0.05 + (1. - player_dist / max_dist) * 0.95
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
	
	for i in 60:
		var rand_pos = Vector2.from_angle(randf_range(0, TAU)) * level_radius
		
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
	circle.radius = 150
	
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

func spawn_arrow(size: float, arrow_size: float, color: Color) -> ArrowIndicator:
	var new_arrow: ArrowIndicator = arrow_scene.instantiate()
	new_arrow.arrow_size = arrow_size
	new_arrow.color = color
	new_arrow.scale.y = size
	$AttackIndicators.add_child(new_arrow)
	return new_arrow

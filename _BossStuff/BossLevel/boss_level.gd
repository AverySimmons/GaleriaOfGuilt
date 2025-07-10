extends Node2D

@onready var entities: Node2D = $Entities
@onready var attack_indicators: Node2D = $AttackIndicators
@onready var blood_manager: BloodManager = $Level/BloodManager
@onready var camera: Camera2D = $Camera2D
@onready var walls: Sprite2D = $Level/Walls
@onready var inner_walls: Sprite2D = $Level/Walls/InnerWalls
@onready var level: Node2D = $Level
@onready var sand_effect: ColorRect = $CanvasLayer/SandEffect
@onready var sand_particles: GPUParticles2D = $Camera2D/SandParticles
@onready var overlay: Control = $CanvasLayer/Overlay


var arrow_scene = preload("res://03_Components/arrow_indicator.tscn")

var enemy_scenes = {
	preload("res://01_Source/01_Combat/Enemies/lizard.tscn") : 15.,
	preload("res://01_Source/01_Combat/Enemies/worm.tscn") : 10.,
	preload("res://01_Source/01_Combat/Enemies/locust.tscn") : 5.,
}

var upgraded_scenes = {
	"Locust" : preload("res://01_Source/01_Combat/Enemies/blood_locust.tscn"),
	"Worm" : preload("res://01_Source/01_Combat/Enemies/blood_worm.tscn"),
	"Lizard" : preload("res://01_Source/01_Combat/Enemies/blood_lizard.tscn")
}

var enemy_spawn_scene = preload("res://01_Source/01_Combat/Enemies/EnemySpawn/enemy_spawn.tscn")

var boss_scene = preload("res://_BossStuff/00_BossLogic/boss.tscn")

@export var try_again_mode = true

var max_enemies_in_wave = 10
var enemy_credits = 5
var level_radius = 720 - 100
var enemy_player_spacing = 200
var enemy_spacing = 100

var enemies_left = 0

var is_roaming = true
var roaming_window = 25
var roaming_timer = roaming_window

signal boss_defeated()
var timer = 5

var shader_wind1_offset = Vector2.ZERO
var shader_wind2_offset = Vector2.ZERO
var shader_wind_direction: Vector2 = Vector2(1, 0)
var shader_wind_speed = 1.

var is_zooming_in = false

var boss: Boss

@export var inner_wall_rot_speed = 0.5

func _ready() -> void:
	GameData.player.exp_mult = 0
	overlay.hide_xp()
	GameData.player.global_position = $PlayerSpawn.global_position
	GameData.is_escaping = false
	entities.add_child(GameData.player)
	blood_manager.spawn()
	change_wind_dir()
	
	if not try_again_mode:
		var t = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
		t.tween_property(sand_effect, "material:shader_parameter/strength", 1., roaming_window)
		await get_tree().create_timer(15, false).timeout
		
		var t2 = create_tween().set_ease(Tween.EASE_IN)
		t2.tween_property(camera, "zoom", Vector2.ONE * 0.5, roaming_window-15)
	else:
		is_roaming = false
		sand_effect.material.set_shader_parameter("strength", 1)
		camera.zoom = Vector2.ONE * 0.5
		lock_level()

func boss_dies() -> void:
	boss_defeated.emit()

func _process(delta: float) -> void:
	camera.global_position = GameData.player.global_position
	
	if is_zooming_in:
		walls.global_position = camera.global_position
	
	inner_walls.rotate(delta*inner_wall_rot_speed)
	update_wind_shader(delta)

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("levelup_debug"):
		SignalBus.levelup.emit()
	
	if is_roaming:
		
		
		roaming_timer -= delta
		if roaming_timer < 0:
			is_roaming = false
			
			lock_level()
	

func update_wind_shader(delta) -> void:
	var shader: ShaderMaterial = sand_effect.material
	
	var particles: ParticleProcessMaterial = sand_particles.process_material
	
	shader_wind1_offset += 0.5 * shader_wind_direction * delta * shader_wind_speed
	shader_wind2_offset += 0.5 * shader_wind_direction.rotated(1.) * delta * shader_wind_speed
	
	shader.set_shader_parameter("player_pos", camera.global_position)
	shader.set_shader_parameter("wind1_offset", shader_wind1_offset)
	shader.set_shader_parameter("wind2_offset", shader_wind2_offset)
	shader.set_shader_parameter("zoom", camera.zoom.x)
	
	particles.initial_velocity_min = shader_wind_direction.length() * 1000
	var particle_dir = shader_wind_direction.rotated(0.5)
	particles.direction = Vector3(particle_dir.x, particle_dir.y, 0)
	sand_particles.self_modulate.a = shader.get_shader_parameter("strength")

func change_wind_dir() -> void:
	await get_tree().create_timer(randf_range(5, 8), false).timeout
	var new_wind_dir = Vector2.from_angle(randf_range(0,TAU)) * 1.
	var t = create_tween().set_ease(Tween.EASE_IN)
	t.tween_method(set_wind_dir, shader_wind_direction, new_wind_dir, 2.)
	await t.finished
	change_wind_dir()

func set_wind_dir(new_dir) -> void:
	shader_wind_direction = new_dir

func spawn_boss() -> void:
	overlay.show_boss_health_bar()
	boss = boss_scene.instantiate()
	boss.global_position = level.global_position
	boss.entities = entities
	boss.indicators_node = attack_indicators
	SignalBus.change_phase.connect(trigger_phase)
	boss.spawn_enemies.connect(populate_enemies)
	boss.boss_dies.connect(boss_dies)
	entities.add_child(boss)
	
	phase1()

func try_again_setup() -> void:
	pass

func lock_level() -> void:
	is_zooming_in = true
	walls.global_position = camera.global_position
	walls.scale = Vector2.ONE / camera.zoom + Vector2.ONE * 0.1
	
	var t2 = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	t2.tween_property(walls, "scale", Vector2.ONE, 0.5)
	await t2.finished
	
	is_zooming_in = false
	
	GameData.boss_fight_offset = camera.global_position
	level.global_position = GameData.boss_fight_offset
	walls.global_position = level.global_position
	
	var t3 = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	t3.tween_property(camera, "zoom", Vector2.ONE, 0.75)
	await t3.finished
	
	var top_left = $Level/TopLeft.global_position
	var bot_right = $Level/BottomRight.global_position
	camera.limit_left = top_left.x
	camera.limit_top = top_left.y
	camera.limit_right = bot_right.x
	camera.limit_bottom = bot_right.y
	
	SignalBus.death.connect(enemy_died)
	
	spawn_boss()

func upgrade_enemy(enemy: Enemy) -> void:
	var new_enemy: Enemy = upgraded_scenes[enemy.type].instantiate()
	new_enemy.global_position = enemy.global_position
	new_enemy.level = self
	new_enemy.indicator_node = attack_indicators
	new_enemy.bullet_node = entities
	if enemy.target_ind: enemy.target_ind.conceal()
	enemy.queue_free()
	entities.add_child(new_enemy)

func enemy_died(enemy) -> void:
	enemies_left -= 1
	if enemies_left <= 0:
		boss.initiate_falling()

func trigger_phase(val):
	match val:
		2:
			phase2()
		3:
			phase3()

func phase1() -> void:
	populate_enemies()

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
		await get_tree().create_timer(5, false).timeout

func spawn_wave(enemy_list):
	var spawns = get_spawn_point_list()
	
	var scored_spawns = score_spawn_list(spawns)
	#print("new wave:")
	#print(spawns)
	#print(scored_spawns)
	#print(enemy_list)
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
		var rand_pos = Vector2.from_angle(randf_range(0, TAU)) * randf_range(0, level_radius) \
			+ GameData.boss_fight_offset
		
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
	new_enemy_spawn.spawn_time = 1
	new_enemy_spawn.boss = boss
	entities.add_child(new_enemy_spawn)

func spawn_arrow(size: float, arrow_size: float, color: Color) -> ArrowIndicator:
	var new_arrow: ArrowIndicator = arrow_scene.instantiate()
	new_arrow.arrow_size = arrow_size
	new_arrow.color = color
	new_arrow.scale.y = size
	$AttackIndicators.add_child(new_arrow)
	return new_arrow

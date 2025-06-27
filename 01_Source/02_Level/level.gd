class_name Level
extends Node2D

@onready var entities: Node2D = $Entities
@onready var camera: Camera2D = $Camera2D
@onready var blood_manager: BloodManager = $BloodManager
@onready var doors: Node2D = $Doors

var enemies_left = 0
var enemy_credits = 0

var top_left: Vector2
var bot_right: Vector2

signal item_picked_up()

var item

var escape_timer = 0
var distance = 0

var mall_scaling: Array[float] = [
	1, 2, 3, 4, 5
]

var mall_flat: Array[float] = [
	1, 2, 3, 4, 5
]

var size_scaling: Array[float] = [
	1, 2, 3, 4
]

var enemy_spawn_scene = preload("res://01_Source/01_Combat/Enemies/EnemySpawn/enemy_spawn.tscn")
var item_scene = preload("res://01_Source/02_Level/Item/item.tscn")

var enemy_scenes = [
	preload("res://01_Source/01_Combat/Enemies/worm.tscn"),
	preload("res://01_Source/01_Combat/Enemies/locust.tscn")
]

var item_sprites = [
	preload("res://00_Assets/00_Sprites/Objective_item_sprites/compact_mirror_sprite.png"),
	preload("res://00_Assets/00_Sprites/Objective_item_sprites/heart_shaped_sunglasses_sprite.png"),
	preload("res://00_Assets/00_Sprites/Objective_item_sprites/human_heart_sprite.png"),
	preload("res://00_Assets/00_Sprites/Objective_item_sprites/lamb_plush_sprite.png"),
	preload("res://00_Assets/00_Sprites/Objective_item_sprites/ring_sprite.png")
]

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
	
	var con_num = -1
	for c in connections: if c: con_num += 1
	
	enemy_credits = mall_flat[GameData.mall_ind] + \
		mall_scaling[GameData.mall_ind] * distance + \
		size_scaling[con_num]
	
	$MultiplyLayer.color = tint
	SignalBus.death.connect(enemy_died)
	
	top_left = $TopLeft.global_position
	bot_right = $BottomRight.global_position
	camera.limit_left = top_left.x
	camera.limit_top = top_left.y
	camera.limit_right = bot_right.x
	camera.limit_bottom = bot_right.y
	
	#var center = Vector3((top_left.x+bot_right.x) * 0.5, (top_left.y+bot_right.y) * 0.5, 0)
	#var size = Vector3(bot_right.x-top_left.x, bot_right.y-top_left.y, 0)
	#blood_manager.multimesh.custom_aabb = AABB(center, size)
	
	for d in doors.get_children():
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
	
	if GameData.is_escaping:
		GameData.music_event.set_parameter("combat state", 2)
	elif enemies_left > 0:
		GameData.music_event.set_parameter("combat state", 1)
	else:
		GameData.music_event.set_parameter("combat state", 0)

func _physics_process(delta: float) -> void:
	if not GameData.is_escaping: return
	var con_num = -1
	for c in connections: if c: con_num += 1
	enemy_credits = (mall_flat[GameData.mall_ind] + size_scaling[con_num]) * 1.5
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
	var space_state = get_world_2d().direct_space_state
	var circle = CircleShape2D.new()
	circle.radius = 100
	
	for ei in enemy_credits:
		for try in 10:
			var rand_pos = Vector2(randf_range(top_left.x+100, bot_right.x-100), \
				randf_range(top_left.y+100, bot_right.y-100))
			
			if rand_pos.distance_to(GameData.player.global_position) < 200:
				continue
			
			var params = PhysicsShapeQueryParameters2D.new()
			params.shape = circle
			params.transform = Transform2D(0, rand_pos)
			params.collide_with_areas = false
			params.collide_with_bodies = true
			var collided = space_state.intersect_shape(params, 1)
			
			if collided: continue
			
			spawn_enemy(rand_pos, randi_range(0, 1))
			enemies_left += 1
			break

func spawn_enemy(pos: Vector2, index: int) -> void:
	var new_enemy = enemy_scenes[index].instantiate()
	if index == 0:
		new_enemy.bullet_node = entities
	var new_enemy_spawn = enemy_spawn_scene.instantiate()
	new_enemy_spawn.entities_node = entities
	new_enemy_spawn.global_position = pos
	new_enemy_spawn.enemy = new_enemy
	new_enemy_spawn.spawn_time = 0.5 if GameData.is_escaping else 1
	entities.add_child(new_enemy_spawn)

func enemy_died(enemy) -> void:
	enemies_left -= 1

func enter(dir: Vector2) -> void:
	blood_manager.spawn()
	if map_pos == Vector2.ZERO:
		GameData.player.global_position = Vector2.ZERO
		entities.add_child(GameData.player)
		return
	
	for d: Door in doors.get_children():
		if d.direction == dir * -1:
			GameData.player.global_position = d.player_spawn.global_position
			entities.add_child(GameData.player)
			break

func exit(dir: Vector2):
	if enemies_left > 0 and not GameData.is_escaping: return
	entities.remove_child(GameData.player)
	exited_room.emit(dir)

func item_interact():
	item_picked_up.emit()
	

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
	preload("res://01_Source/01_Combat/Enemies/locust.tscn"),
	preload("res://01_Source/01_Combat/Enemies/lizard.tscn")
]

var item_sprites = [
	preload("res://00_Assets/00_Sprites/Objective_item_sprites/heart_shaped_sunglasses_sprite.png"),
	preload("res://00_Assets/00_Sprites/Objective_item_sprites/compact_mirror_sprite.png"),
	preload("res://00_Assets/00_Sprites/Objective_item_sprites/ring_sprite.png"),
	preload("res://00_Assets/00_Sprites/Objective_item_sprites/lamb_plush_sprite.png"),
	preload("res://00_Assets/00_Sprites/Objective_item_sprites/human_heart_sprite.png"),
]

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
	map_piece.visible = true
	var con_num = -1
	for c in connections: if c: con_num += 1
	
	enemy_credits = mall_flat[GameData.mall_ind] + \
		mall_scaling[GameData.mall_ind] * distance
	
	enemy_credits *= size_scaling[con_num]
	
	$MultiplyLayer.color = tint
	SignalBus.death.connect(enemy_died)
	
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
	
	if GameData.is_escaping:
		GameData.music_event.set_parameter("combat state", 2)
	elif enemies_left > 0:
		GameData.music_event.set_parameter("combat state", 1)
	else:
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
	for ei in enemy_credits:
		for try in 100:
			var rand_pos = Vector2(randf_range(top_left.x+100, bot_right.x-100), \
				randf_range(top_left.y+100, bot_right.y-100))
			
			if not check_enemy_spawn(rand_pos): continue
			
			spawn_enemy(rand_pos, randi_range(0, 2))
			enemies_left += 1
			break

func check_enemy_spawn(pos: Vector2) -> bool:
	var player_pos = GameData.player.global_position
	if pos.distance_to(player_pos) < 300: return false
	
	var space_state = get_world_2d().direct_space_state
	var circle = CircleShape2D.new()
	circle.radius = 200
	
	var params = PhysicsShapeQueryParameters2D.new()
	params.shape = circle
	params.transform = Transform2D(0, pos)
	params.collide_with_areas = false
	params.collide_with_bodies = true
	var collided = space_state.intersect_shape(params)
	
	return not collided

func spawn_enemy(pos: Vector2, index: int) -> void:
	var new_enemy = enemy_scenes[index].instantiate()
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

func enter(dir: Vector2) -> void:
	enter_timer = 0.5
	blood_manager.spawn()
	if dir == Vector2.ZERO:
		GameData.player.global_position = entrance_door.player_spawn.global_position
		entities.add_child(GameData.player)
		return
	
	for d: Door in doors.get_children():
		if d.direction == dir * -1:
			GameData.player.global_position = d.player_spawn.global_position
			entities.add_child(GameData.player)
			break

func exit(dir: Vector2):
	if enter_timer > 0: return
	if enemies_left > 0 and not GameData.is_escaping: return
	
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

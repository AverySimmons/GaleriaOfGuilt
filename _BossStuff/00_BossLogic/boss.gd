extends Node2D

@onready var player: Player = GameData.player
@onready var camera: Camera2D
@onready var heart_sprite: Sprite2D = $Heart
@onready var heartbeat_ap: AnimationPlayer = $HeartBeat
@onready var tornado_spawn_ap: AnimationPlayer = $TornadoSpawning
@onready var tornado_spawn: Sprite2D = $TornadoSpawn
@onready var lightning_spawn_ap: AnimationPlayer = $LightningSpawning
@onready var lightning_spawn: Sprite2D = $LightningSpawn
@onready var upgrade_proj_scene = preload("res://_BossStuff/02_BossProjectiles/upgrade_projectile.tscn")
@onready var lightning_module: BossLightningModule = $BossLightningModule
@onready var test_player_scene = preload("res://01_Source/00_Player/Player.tscn")
@onready var sprinkler_scene = preload("res://_BossStuff/02_BossProjectiles/boss_tornado.tscn")

## boss should drop down a little when attacking so its more clearly in view?
## might be bad for visiblity of enemies though

var entities
# State variables =================================================================
const MOVING: int = 0
const LIGHTNING: int = 1
const SPRINKLER: int = 2
const FALLING: int = 3
const GROUND: int = 4
const RISING: int = 5
var cur_state: int = MOVING

var phase: int = 2
var can_attack: bool = true

# Movement variables ==============================================================
@onready var movement_point: Node2D = $MovementPoint

const Y_OFFSET_RANGE: float = -700
var y_offset: float = Y_OFFSET_RANGE
var y_variance: float = 30
var y_top_speed: float = 7
var y_speed: float
var y_direction: int = -1 # 1 is down, -1 is up
var y_acceleration: float = y_top_speed/0.2

# Special Move Timers ============================================================
var special_move_time_phase2: float = 7.0
var special_move_time_phase3: float = 5.0
var special_move_timer: float = 0.0
var will_be_lightning: bool = false

# Lightning variables ============================================================
const MAX_LIGHTNING_AMT_P2: int = 2
const MAX_LIGHTNING_AMT_P3: int = 4
var lightning_time: float = 6
var lightning_timer: float = lightning_time
var lightning_amt: int = 0

# Sprinkler variables =============================================================
const AMT_SPRINKLERS_P2: int = 2
const AMT_SPRINKLERS_P3: int = 3
const BETWEEN_SPRINKLERS_TIME: int = 1
var amt_sprinklers: int
var sprinkler_timer: float
var between_sprinklers_timer: float
var last_sprinkler_angle: float
var sprinklers_placed: int
var radius_from_player: Vector2 = Vector2(400, 0)

# Enemy upgrade
signal upgrade_enemy(enemy: Enemy)

const ENEMY_INTERVAL_LOWER: int = 2
const ENEMY_INTERVAL_UPPER: int = 4
const TIME_UNTIL_UPGRADE_SHOT: int = 2

var upgrade_timer: float = 4
var amt_to_upgrade: float = 4
var chosen_interval: float = 4
var was_before_threshold: bool = true

var list_of_unupgraded_enemies: Array[Enemy]

# references to other nodes
var entities_node
var indicators_node

func _ready() -> void:
	lightning_module.indicator_node = indicators_node
	global_position = movement_point.global_position
	heart_sprite.global_position += Vector2(0, y_offset)
	heartbeat_ap.play("HeartBeat")
	SignalBus.death.connect(remove_from_selectable)
	pass

func _physics_process(delta: float) -> void:
	if !heartbeat_ap.is_playing():
		heartbeat_ap.play("HeartBeat")
	
	# Determining state
	if can_attack && special_move_timer>0:
		special_move_timer = move_toward(special_move_timer, 0, delta)
	if special_move_timer <= 0:
		initiate_attack()
	# Movement stuff
	match cur_state:
		MOVING:
			movement_point.start_moving()
			heartbeat_ap.speed_scale = 1.0
			# Moving to movement point
			move_to_movement_point()
			# Adjust heart y position
			adjust_heart_y_pos(delta)
		LIGHTNING:
			if !lightning_spawn_ap.is_playing():
				lightning_spawn_ap.play("lightning_spawning")
			lightning_spawn.global_position = heart_sprite.global_position
			movement_point.stop_moving()
			adjust_heart_y_pos(delta)
			heartbeat_ap.speed_scale = 2.0
			lightning_timer = move_toward(lightning_timer, 0, delta)
			if lightning_timer <= 0:
				cur_state = MOVING
				lightning_spawn.visible = false
		SPRINKLER:
			if !tornado_spawn_ap.is_playing():
				tornado_spawn_ap.play("tornado_spawn")
			tornado_spawn.global_position = heart_sprite.global_position
			movement_point.stop_moving()
			adjust_heart_y_pos(delta)
			heartbeat_ap.speed_scale = 2.0
			# Control logic of if it should end
			sprinkler_timer = move_toward(sprinkler_timer, 0, delta)
			if sprinkler_timer <= 0:
				cur_state = MOVING
				tornado_spawn.visible = false
				amt_sprinklers = 0
				sprinklers_placed = 0
			# Control when it should place sprinklers
			between_sprinklers_timer = move_toward(between_sprinklers_timer, 0, delta)
			if between_sprinklers_timer <= 0:
				between_sprinklers_timer = BETWEEN_SPRINKLERS_TIME
				place_sprinkler()
		FALLING:
			pass
		GROUND:
			pass
		RISING: 
			pass
	
	
	if !can_attack:
		return
	
	upgrade_timer = move_toward(upgrade_timer, 0, delta)
	
	if upgrade_timer <= 0 && was_before_threshold:
		upgrade_enemies()
		was_before_threshold = false
	
	pass

func move_to_movement_point() -> void:
	# Moving to movement point
	var t = create_tween()
	t.tween_property(self, "global_position", movement_point.global_position, 0.3)
	return

func adjust_heart_y_pos(delta: float) -> void:
	# Correct direction
	if y_offset <= Y_OFFSET_RANGE-y_variance:
		y_direction = 1
	elif y_offset >= Y_OFFSET_RANGE+y_variance:
		y_direction = -1
	
	y_speed = move_toward(y_speed, y_top_speed*y_direction, y_acceleration*delta)
	y_offset += y_speed
	heart_sprite.global_position.y = global_position.y + y_offset
	
	return

func change_phase(current_phase: int) -> void:
	phase = current_phase + 1
	SignalBus.change_phase.emit(phase)
	can_attack = true
	
	# Setting special move timer to begin with:
	match phase:
		2:
			special_move_timer = special_move_time_phase2/2.0
		3:
			special_move_timer = special_move_time_phase3/2.0
	# Enter room gain blood upgrade lets you gain blood when phase changes
	if UpgradeData.upgrades_gained[UpgradeData.ENTER_ROOM]:
		GameData.player.gain_blood_other(80)
		GameData.player.dealt_damage_took_damage = true
	return

func choose_enemies() -> Array[Enemy]:
	var chosen_enemies: Array[Enemy]
	if list_of_unupgraded_enemies.size() <= amt_to_upgrade:
		return list_of_unupgraded_enemies
	
	for i in range(amt_to_upgrade):
		var random: int = randi_range(0, list_of_unupgraded_enemies.size()-1)
		chosen_enemies.append(list_of_unupgraded_enemies[random])
		list_of_unupgraded_enemies.remove_at(random)
	return chosen_enemies

func upgrade_enemies() -> void:
	# Make sure there are enemies to upgrade
	if list_of_unupgraded_enemies.size() == 0:
		upgrade_timer = 1
		was_before_threshold = true
		return
	var chosen_enemies: Array[Enemy] = choose_enemies()
	
	for enemy in chosen_enemies:
		enemy.mark_for_upgrade()
	
	await get_tree().create_timer(2, false).timeout
	if cur_state in [FALLING, GROUND, RISING] || !is_inside_tree():
		return
	for enemy in chosen_enemies:
		if is_instance_id_valid(enemy.get_instance_id()):
			var upgrade_proj = upgrade_proj_scene.instantiate()
			upgrade_proj.global_position = global_position
			upgrade_proj.get_shot(y_offset, enemy.global_position)
			entities.add_child(upgrade_proj)
	
	# For resetting the timer:
	was_before_threshold = true
	var upgrade_time: int = randi_range(ENEMY_INTERVAL_LOWER, ENEMY_INTERVAL_UPPER)
	upgrade_timer = upgrade_time
	chosen_interval = upgrade_timer
	if phase == 1:
		amt_to_upgrade = upgrade_time
	elif phase == 2:
		amt_to_upgrade = int(round(upgrade_time * 1.5))
	elif phase == 3:
		amt_to_upgrade = int(round(upgrade_time * 2))
	return

func remove_from_selectable(enemy: Enemy) -> void:
	list_of_unupgraded_enemies.erase(enemy)
	return

func initiate_attack() -> void:
	if phase == 1:
		return
	var chosen_attack = choose_attack()
	match chosen_attack:
		0:
			start_lightning_attack()
		1:
			start_sprinkler_attack()
	return

func choose_attack() -> int:
	var chosen_attack: int # 0 for sprinkler, 1 for lightning
	if will_be_lightning:
		chosen_attack = 0
	else:
		chosen_attack = randi_range(1, 1)
	return chosen_attack

func start_lightning_attack() -> void:
	cur_state = LIGHTNING
	lightning_spawn.visible = true
	match phase:
		1:
			return
		2:
			if lightning_amt < MAX_LIGHTNING_AMT_P2:
				lightning_module.add_lightning(1)
				lightning_amt += 1
			special_move_timer = special_move_time_phase2 + lightning_time
		3:
			if lightning_amt < MAX_LIGHTNING_AMT_P3:
				lightning_module.add_lightning(2)
				lightning_amt += 2
			special_move_timer = special_move_time_phase3 + lightning_time
	lightning_module.activate(lightning_time)
	lightning_timer = lightning_time
	return

func start_sprinkler_attack() -> void:
	sprinklers_placed = 0
	cur_state = SPRINKLER
	tornado_spawn.visible = true
	match phase:
		1:
			return
		2:
			# Give time for warmup and time for each sprinkler placement
			sprinkler_timer = (AMT_SPRINKLERS_P2+1) * BETWEEN_SPRINKLERS_TIME
			between_sprinklers_timer = BETWEEN_SPRINKLERS_TIME
			amt_sprinklers = AMT_SPRINKLERS_P2
			special_move_timer = special_move_time_phase2 + sprinkler_timer
			pass
		3:
			sprinkler_timer = (AMT_SPRINKLERS_P3+1) * BETWEEN_SPRINKLERS_TIME
			between_sprinklers_timer = BETWEEN_SPRINKLERS_TIME
			amt_sprinklers = AMT_SPRINKLERS_P3
			special_move_timer = special_move_time_phase3 + sprinkler_timer
			pass
	return

func place_sprinkler() -> void:
	# This function places sprinklers along an oval from the player, and the radius of that oval is
	# defined up above in radius_from_player where x is that value, and y is that value*9/16 (so it's like the screen
	# and it'll randomize the angle to shift that position from along the radius, taking into account the previous sprinkler
	if sprinklers_placed >= amt_sprinklers:
		return
	var position_for_sprinkler: Vector2
	var angle_to_place: float
	
	if sprinklers_placed == 0:
		angle_to_place = randf_range(0, TAU)
	else:
		var bounds: float = -last_sprinkler_angle
		angle_to_place = randf_range(angle_to_place-(TAU/6), angle_to_place+(TAU/6))
	position_for_sprinkler = radius_from_player.rotated(angle_to_place)
	position_for_sprinkler.y *= 9/16.
	var t: Tween = create_tween()
	t.tween_property(self, "global_position", player.global_position+position_for_sprinkler, 0.3)
	if !is_inside_tree():
		return
	await get_tree().create_timer(0.6).timeout
	if cur_state != SPRINKLER:
		return
	#print("Placing")
	var cur_tornado: Node2D = sprinkler_scene.instantiate()
	cur_tornado.z_offset = y_offset
	cur_tornado.global_position = global_position
	cur_tornado.entities_node = entities
	entities.add_child(cur_tornado)
	sprinklers_placed += 1
	last_sprinkler_angle = angle_to_place
	return

func initiate_falling() -> void:
	cur_state = FALLING
	# interrupt whatever it's doing: moving, lightning (activating the lightning, and remove current lightning maybe?)
	# sprinkler (placing sprinklers, moving, maybe get rid of current sprinklers?) and set vars to default
	# stop attack cooldown timer/other timers and set them all to 0, stop movement_point, y_speed to 0
	
	## I think dont get rid of sprinklers is fine
	
	lightning_module.stop()
	##
	lightning_module.resume()
	
	can_attack = false
	return

func take_damage() -> void:
	SignalBus.boss_health_changed.emit() # needs boss health percent in emit

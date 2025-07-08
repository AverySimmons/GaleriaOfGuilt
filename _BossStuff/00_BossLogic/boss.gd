extends Node2D

@onready var player: Player = GameData.player
@onready var camera: Camera2D
@onready var heart_sprite: Sprite2D = $Heart
@onready var heartbeat_ap: AnimationPlayer = $HeartBeat
@onready var upgrade_proj_scene = preload("res://_BossStuff/02_BossProjectiles/upgrade_projectile.tscn")
var entities
# State variables =================================================================
var moving_state: bool = true
var lightning_state: bool = false
var sprinkler_state: bool = false
var falling_state: bool = false
var ground_state: bool = false
var phase: int = 1

# Movement variables ==============================================================
@onready var movement_point: Node2D = $MovementPoint

const Y_OFFSET_RANGE: float = -500
var y_offset: float = Y_OFFSET_RANGE
var y_variance: float = 30
var y_top_speed: float = 7
var y_speed: float
var y_direction: int = -1 # 1 is down, -1 is up
var y_acceleration: float = y_top_speed/0.2

# Special Move Timers ============================================================
var special_move_time_phase2: float = 7.0
var special_move_time_phase3: float = 5.0
var special_move_timer: float = 0

# Lightning variables ============================================================
var lightning_time: float
var lightning_timer: float = lightning_time

# Sprinkler variables =============================================================
var sprinkler_time: float
var sprinkler_timer: float = sprinkler_time

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

func _ready() -> void:
	global_position = movement_point.global_position
	heart_sprite.global_position += Vector2(0, y_offset)
	heartbeat_ap.play("HeartBeat")
	SignalBus.death.connect(remove_from_selectable)
	pass

func _physics_process(delta: float) -> void:
	if !heartbeat_ap.is_playing():
		heartbeat_ap.play("HeartBeat")
	
	# Determining state
	if !(phase == 1):
		special_move_timer = move_toward(special_move_timer, 0, delta)
	# Movement stuff
	if moving_state:
		# Moving to movement point
		move_to_movement_point()
		# Adjust heart y position
		adjust_heart_y_pos(delta)
	
	
	
	
	
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
	
	# Setting special move timer to begin with:
	match phase:
		2:
			special_move_timer = special_move_time_phase2/2.0
		3:
			special_move_timer = special_move_time_phase3/2.0
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
	
	await get_tree().create_timer(2).timeout
	if falling_state || ground_state:
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

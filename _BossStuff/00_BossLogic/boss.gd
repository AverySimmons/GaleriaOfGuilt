extends Node2D

@onready var player: Player = GameData.player
@onready var camera: Camera2D
@onready var heart_sprite: Sprite2D = $Heart
@onready var heartbeat_ap: AnimationPlayer = $HeartBeat
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

# Lightning variables ============================================================
const PHASE_TWO_LIGHTNING_TIME: float = 8
const PHASE_THREE_LIGHTNING_TIME: float = 6
var lightning_time: float
var lightning_timer: float = lightning_time

# Sprinkler variables =============================================================
var sprinkler_time: float
var sprinkler_timer: float = sprinkler_time

func _ready() -> void:
	global_position = movement_point.global_position
	heart_sprite.global_position += Vector2(0, y_offset)
	heartbeat_ap.play("HeartBeat")
	pass

func _physics_process(delta: float) -> void:
	if !heartbeat_ap.is_playing():
		heartbeat_ap.play("HeartBeat")
	# movement stuff
	if moving_state:
		# Moving to movement point
		move_to_movement_point()
		# Adjust heart y position
		adjust_heart_y_pos(delta)
	
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
	return

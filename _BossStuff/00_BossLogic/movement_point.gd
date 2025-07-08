extends Node2D

const Y_OFFSET: float = 200
const X_OFFSET_BOUND: float = 500 # 640 for a bit more than fullscreen --- check the math on acceleration changing speed
const TOP_SPEED: float = 250

@onready var player: Player = GameData.player
@onready var camera: Camera2D = $Boss.camera

var speed: float = 0
var acceleration: float = TOP_SPEED / 0.1
var direction: float = -1 # -1 means going left, 1 means going right
var x_offset: float = 0
var offsets: Vector2 = Vector2(x_offset, Y_OFFSET)

func _ready() -> void:
	global_position = camera.position + offsets
	#global_position = Vector2(620, 360) + offsets
	pass

func _physics_process(delta: float) -> void:
	
	# Offset stuff: X offset is calculated and applied to player position, and y offset is applied to player position
	if x_offset <= -X_OFFSET_BOUND:
		direction = 1
	elif x_offset >= X_OFFSET_BOUND:
		direction = -1
	
	speed = move_toward(speed, TOP_SPEED*direction, acceleration*delta)
	x_offset += speed*delta
	
	# apply offsets to player global pos to find this dude's position
	offsets = Vector2(x_offset, Y_OFFSET)
	global_position = camera.position + offsets # should be camera
	#global_position = Vector2(620, 360) + offsets
	pass

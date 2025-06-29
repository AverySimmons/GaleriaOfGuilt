extends Node2D

@onready var camera: Camera2D = $Camera2D

var camera_x: float = 0
var bumb_timer = 1
var bumb_direction : Vector2 = Vector2.ZERO

@export var noise : FastNoiseLite
var time_passed := 0.0

func _process(delta: float) -> void:
	time_passed += delta * 20
	camera_x += delta * 200
	
	var x_offset = noise.get_noise_1d(time_passed) * 5
	var y_offset = noise.get_noise_1d(time_passed + 100) * 20
	
	camera.position = Vector2(camera_x + x_offset, 360 + y_offset)

func set_scene(is_night: bool):
	if is_night:
		$Morning.visible = false
		$Night.visible = true
	else:
		$Morning.visible = true
		$Night.visible = false

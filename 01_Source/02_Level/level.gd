class_name Level
extends Node2D

# 0 is no connection
# 1 is up
# 2 is down
var connections: Array[bool] = [0, 0, 0, 0]
var is_end: bool = false
var map_pos: Vector2 = Vector2.ZERO
var map_piece: MapPiece = null

var player: Player

var blood_scene = preload("res://01_Source/01_Combat/Blood/blood_particle.tscn")

func _physics_process(delta: float) -> void:
	print(Engine.get_frames_per_second())
	if Input.is_action_just_pressed("main_attack"):
		blood_splatter(get_global_mouse_position())

func blood_splatter(pos):
	for i in 5:
		$BloodManager.spawn_blood_clump(pos,  \
			Vector2.from_angle(randf_range(-PI,PI)) * randf_range(300, 600))

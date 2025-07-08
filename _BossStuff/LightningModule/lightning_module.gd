class_name BossLightningModule
extends Node

signal finished()

const level_radius = 360

var blood_lightning_scene = preload("res://_BossStuff/LightningModule/blood_lightning.tscn")
var indicator_node: Node2D

var animation_finished = false

var base_lightning_acc = 250
var speed_up_lightning_acc = 3000
var acc = base_lightning_acc
var spawners: Array[BossLightningSpawner]

func add_lightning(num: int) -> void:
	var start_angle = randf_range(0, TAU)
	
	for i in num:
		var new_spawner = BossLightningSpawner.new()
		new_spawner.velocity = Vector2.ZERO
		new_spawner.pos = Vector2.from_angle(start_angle) * level_radius + GameData.boss_fight_offset
		spawners.push_back(new_spawner)
		start_angle += TAU / float(num)

func activate(time: float) -> void:
	acc = speed_up_lightning_acc
	await get_tree().create_timer(time,false).timeout
	acc = base_lightning_acc
	finished.emit()

func _physics_process(delta: float) -> void:
	for s in spawners:
		var dir = s.pos.direction_to(GameData.player.global_position)
		s.velocity += dir * acc * delta
		s.pos += s.velocity * delta
		
		if s.pos.distance_to(s.last_spawn_position) > 45:
			spawn_lightning(s.pos)
			s.last_spawn_position = s.pos

func spawn_lightning(pos: Vector2) -> void:
	var new_lightning = blood_lightning_scene.instantiate()
	new_lightning.global_position = pos
	indicator_node.add_child(new_lightning)

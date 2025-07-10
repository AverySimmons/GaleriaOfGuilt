class_name BossLightningModule
extends Node

signal finished()

const level_radius = 360

var blood_lightning_scene = preload("res://_BossStuff/LightningModule/blood_lightning.tscn")
var indicator_node: Node2D

var base_lightning_acc = 250
var speed_up_lightning_acc = 3000
var spawners: Array[BossLightningSpawner]

var timer = 0
var state: int:
	set(val):
		state = val
		if val == PASSIVE:
			for s in spawners:
				s.velocity = Vector2.ZERO

enum {STOPPED, PASSIVE, ACTIVE}

func _ready() -> void:
	state = PASSIVE

func add_lightning(num: int) -> void:
	var start_angle = randf_range(0, TAU)
	
	for i in num:
		var new_spawner = BossLightningSpawner.new()
		new_spawner.velocity = Vector2.ZERO
		new_spawner.pos = Vector2.from_angle(start_angle) * level_radius + GameData.boss_fight_offset
		spawners.push_back(new_spawner)
		start_angle += TAU / float(num)

func activate(time: float) -> void:
	state = ACTIVE
	timer = time

func stop() -> void:
	state = STOPPED
	timer = 0

func resume() -> void:
	state = PASSIVE

func _physics_process(delta: float) -> void:
	timer -= delta
	if timer < 0 and state == ACTIVE:
		state = PASSIVE
	
	var acc
	match state:
		STOPPED:
			acc = 0
		PASSIVE:
			acc = base_lightning_acc
		ACTIVE:
			acc = speed_up_lightning_acc
	
	if state == STOPPED:
		return
	
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

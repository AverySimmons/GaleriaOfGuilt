extends Node

signal finished()

var blood_lightning_scene = preload("res://_BossStuff/LightningModule/blood_lightning.tscn")
var indicator_node: Node2D

var spawning_window = 3
var animation_window = 2

var spawning_timer = 0
var animation_timer = 0

var animation_finished = false

var spawner_num = 3
var lightning_acc = 2000
var spawners: Array[BossLightningSpawner]

func activate() -> void:
	spawning_timer = spawning_window
	animation_timer = animation_window
	animation_finished = false
	
	spawners = []
	for i in spawner_num:
		var new_spawner = BossLightningSpawner.new()
		new_spawner.velocity = Vector2.ZERO
		new_spawner.pos = Vector2.ZERO

func _physics_process(delta: float) -> void:
	if spawning_timer < 0:
		return
	
	if animation_timer < 0 and not animation_finished:
		finished.emit()
		animation_finished = true
	
	spawning_timer -= delta
	animation_timer -= delta
	
	for s in spawners:
		var dir = s.pos.direction_to(GameData.player.global_position)
		s.velocity += dir * lightning_acc * delta
		s.pos += s.velocity * delta
		
		if s.pos.distance_to(s.last_spawn_position) > 40:
			spawn_lightning(s.pos)

func spawn_lightning(pos: Vector2) -> void:
	var new_lightning = blood_lightning_scene.instantiate()
	new_lightning.global_position = pos
	indicator_node.add_child(new_lightning)

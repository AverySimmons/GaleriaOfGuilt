extends Node2D

@onready var sprite_2d: Sprite2D = $Sprite2D


var bullet_scene = preload("res://_BossStuff/02_BossProjectiles/boss_bullet.tscn")

var bullet_speed = 300
var entities_node
var z_offset: float = 400
var fall_speed = 1000
var total_waves = 30
var wave_cooldown = 0.2
var bullet_num = 5
var wave_timer = wave_cooldown
var cur_rot = randf_range(0, TAU)
var rot_inc = PI / 64.

var wait_timer = 0.5

func _ready() -> void:
	sprite_2d.global_position.y = global_position.y + z_offset - 81
	AudioData.play_sound("tornado_spawn", $TornadoSpawn)

func _process(delta: float) -> void:
	sprite_2d.global_position.y = global_position.y + z_offset - 81
	$ScalingShadow.material.set_shader_parameter("z", -z_offset)

func _physics_process(delta: float) -> void:
	if z_offset != 0:
		z_offset = move_toward(z_offset, 0, delta * fall_speed)
		return
	if wait_timer > 0:
		wait_timer -= delta
		return
	wave_timer -= delta
	if wave_timer <= 0:
		spawn_wave()
		cur_rot += rot_inc
		wave_timer = wave_cooldown
		total_waves -= 1
		if total_waves == 0:
			queue_free()

func spawn_wave() -> void:
	for i in bullet_num:
		var dir = Vector2.from_angle(cur_rot + TAU * i / bullet_num)
		spawn_bullet(dir)
		AudioData.play_sound("tornado_shoot", $TornadoShoot)

func spawn_bullet(dir: Vector2) -> void:
	var new_bullet = bullet_scene.instantiate()
	new_bullet.global_position = global_position
	new_bullet.velocity = dir * bullet_speed
	entities_node.add_child(new_bullet)

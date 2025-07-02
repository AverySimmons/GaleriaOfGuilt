extends Area2D

var velocity: Vector2
var target_location: Vector2
var min_distance: float = 300

var explosion_time: float = 0.4
var timer_until_explosion: float = 2.0
var has_exploded: bool = false
var damage: float
var flinch_amt: float
var knockback_amt: float
var enemies_hit: Dictionary

# Player references
var dealt_damage = GameData.player.dealt_damage_took_damage
var player = GameData.player

# Z variable for grenade arc
var z: float
var z_speed: float = -800
var z_gravity: float = -1500

# Rotation stuff
var rotation_velocity: float = 6
var rotation_friction: float = 2

@onready var explosion_sound = $ExplosionSound

func _ready() -> void:
	monitoring = false
	connect("area_entered", Callable(self, "_on_area_entered"))
	pass

func _physics_process(delta: float) -> void:
	if has_exploded:
		return
	position += velocity * delta
	# For the arc
	z_speed -= z_gravity * delta
	z += z_speed * delta
	$Sprite2D.position.y = z
	if z >= 0:
		explode()
	$Sprite2D.rotation += rotation_velocity * delta
	rotation_velocity -= rotation_friction * delta
	pass

func get_thrown(location: Vector2, shot_speed: float, explo_damage: float, explo_flinch_amt: float, explo_kb: float) -> void:
	var distance = location - global_position
	target_location = location + Vector2(randf_range(-50, 50), randf_range(-50, 50))
	distance = target_location - global_position
	
	velocity = shot_speed * distance.normalized()
	damage = explo_damage
	flinch_amt = explo_flinch_amt
	knockback_amt = explo_kb
	
	var time = 2 * z_speed/z_gravity
	velocity = distance/time
	return

func explode() -> void:
	has_exploded = true
	z_speed = 0
	velocity = Vector2.ZERO
	monitoring = true
	await get_tree().physics_frame
	$Sprite2D.visible = false
	$AnimationPlayer.play("explosion")
	AudioData.play_sound("grenade_explosion", explosion_sound)
	var enemies = get_overlapping_areas()
	for area in enemies:
		var enemy = area.owner
		if enemy is Enemy && !enemies_hit.has(enemy):
			print(enemy)
			enemy.take_damage(damage, flinch_amt, knockback_amt)
			dealt_damage = true
			player.gain_blood("special", 1.0, enemy)
			enemies_hit[enemy] = null
	
	if $ExplosionSound.playing:
		await $ExplosionSound.finished
	else:
		await $AnimationPlayer.finished_animation
	queue_free()
	return

func _on_area_entered(area) -> void:
	var enemy = area.owner
	if enemy is not Enemy || enemies_hit.has(enemy):
		return
	enemy.take_damage(damage, flinch_amt, knockback_amt)
	dealt_damage = true
	player.gain_blood("special", 1.0, enemy)
	enemies_hit[enemy] = null
	pass

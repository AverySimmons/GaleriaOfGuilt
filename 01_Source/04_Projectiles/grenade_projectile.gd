extends Area2D

var velocity: Vector2
var target_location: Vector2

var explosion_time: float = 0.5
var timer_until_explosion: float = 2.0
var has_exploded: bool = false
var damage: float
var flinch_amt: float
var knockback_amt: float
var enemies_hit: Dictionary

# Player references
var blood_bar = GameData.player.blood_bar
var dealt_damage = GameData.player.dealt_damage_took_damage
var bb_hit = GameData.player.bb_hit

# Z variable for grenade arc
var z: float
var z_speed: float
var z_gravity: float = -500

func _ready() -> void:
	monitoring = false
	connect("area_entered", Callable(self, "_on_area_entered"))
	pass

func _physics_process(delta: float) -> void:
	if has_exploded:
		return
	position += velocity * delta
	# For the arc
	z_speed -= z_gravity * 2 * delta
	z += z_speed * delta
	$Sprite2D.position.y = z
	if z >= 0:
		explode()
	pass

func get_thrown(location: Vector2, shot_speed: float, explo_damage: float, explo_flinch_amt: float, explo_kb: float) -> void:
	target_location = Vector2((location.x + randf_range(-50, 50)), location.y + randf_range(-50, 50))
	var distance = target_location - global_position
	velocity = shot_speed * distance.normalized()
	damage = explo_damage
	flinch_amt = explo_flinch_amt
	knockback_amt = explo_kb
	var time = distance.length() / velocity.length()
	z_speed = -0.5 * gravity * time
	return

func explode() -> void:
	print("Ouch!")
	has_exploded = true
	z_speed = 0
	velocity = Vector2.ZERO
	monitoring = true
	# Some sort of blood explosion animation?
	#
	#
	var enemies = get_overlapping_areas()
	for enemy in enemies:
		if enemy is Enemy:
			enemy.take_damage(damage, flinch_amt, knockback_amt)
			dealt_damage = true
			blood_bar += bb_hit
			enemies_hit[enemy] = null
	await get_tree().create_timer(explosion_time).timeout
	queue_free()
	return

func _on_area_entered(enemy) -> void:
	if enemy is not Enemy || enemies_hit.has(enemy):
		return
	enemy.take_damage(damage, flinch_amt, knockback_amt)
	dealt_damage = true
	blood_bar += bb_hit
	enemies_hit[enemy] = null
	pass

extends Area2D

var velocity: Vector2
var max_distance: float = 600
var cur_distance: float = 0
var speed: float
var damage: float
var flinch_amt: float
var direction: Vector2
var air_drag: float
var is_despawning = false

func _ready() -> void:
	connect("area_entered", Callable(self, "_on_area_entered"))
	max_distance = speed * 0.6
	pass

func _physics_process(delta: float) -> void:
	if is_despawning: return
	position += velocity * delta
	cur_distance += abs(velocity.length() * delta)
	
	if cur_distance >= (max_distance*0.8):
		velocity -= direction * air_drag * delta
	
	if (cur_distance >= max_distance) || !is_moving():
		despawn()
	pass

func get_shot(angle_from: float, angle_to: float, shot_speed: float,
			 shot_dmg: float, flinch: float) -> void:
	speed = shot_speed
	var actual_angle: float = randf_range(angle_from, angle_to)
	direction = Vector2(cos(actual_angle), sin(actual_angle))
	velocity = direction * speed
	air_drag = velocity.length() * 2.5
	rotation = velocity.angle() + PI/2.0
	damage = shot_dmg
	flinch_amt = flinch
	return

func _on_area_entered(area) -> void:
	var enemy = area.owner
	if enemy is Enemy:
		GameData.player.dealt_damage_took_damage = true
		GameData.player.gain_blood("special", 1.0/6.0, enemy)
		enemy.take_damage(damage, flinch_amt, 0)
		despawn()
	return

func despawn() -> void:
	if is_despawning: return
	is_despawning = true
	set_deferred("monitoring", false)
	$AnimationPlayer.play("explode")
	$Explosion.play()
	
	if $Explosion.playing:
		await $Explosion.finished
	else:
		await $AnimationPlayer.animation_finished
	queue_free()
	return

func is_moving() -> bool:
	return abs(velocity) > Vector2.ZERO

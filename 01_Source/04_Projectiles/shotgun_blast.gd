extends Area2D

var velocity: Vector2
var max_distance: float = 1200
var cur_distance: float = 0
var speed: float
var damage: float = 15
var flinch_amt: float = 0.1
var direction: Vector2
var air_drag: float

func _ready() -> void:
	connect("area_entered", Callable(self, "_on_area_entered"))
	pass

func _physics_process(delta: float) -> void:
	position += velocity * delta
	cur_distance += velocity.length() * delta
	
	if cur_distance >= (max_distance*0.8):
		velocity -= direction * air_drag * delta
	
	if (cur_distance >= max_distance) || !is_moving():
		despawn()
	pass

# Shotgun tip should be slightly offset for each bullet
func get_shot(shotgun_tip: Vector2, angle_from: float, angle_to: float, shot_speed: float, bb_hitspd_inc) -> void:
	speed = shot_speed * bb_hitspd_inc
	var actual_angle: float = randf_range(angle_from, angle_to)
	direction = Vector2(cos(actual_angle), sin(actual_angle))
	velocity = direction * speed
	air_drag = velocity.length() * 1.5
	
	if has_overlapping_areas():
		pass
	return

func _on_area_entered(enemy) -> void:
	if enemy is Enemy:
		GameData.player.dealt_damage_took_damage = true
		enemy.take_damage(damage, flinch_amt)
		despawn()
	return

func despawn() -> void:
	# Animation?
	#
	#
	queue_free()
	return

func is_moving() -> bool:
	return velocity > Vector2.ZERO

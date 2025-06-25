extends Area2D

var velocity: Vector2
var max_distance: float = 500
var cur_distance: float = 0
var speed: float
var damage: float
var flinch_amt: float
var direction: Vector2
var air_drag: float

func _ready() -> void:
	connect("area_entered", Callable(self, "_on_area_entered"))
	pass

func _physics_process(delta: float) -> void:
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
	
	damage = shot_dmg
	flinch_amt = flinch
	return

func _on_area_entered(area) -> void:
	var enemy = area.owner
	if enemy is Enemy:
		GameData.player.dealt_damage_took_damage = true
		GameData.player.blood_bar += GameData.player.bb_hit_actual
		enemy.take_damage(damage, flinch_amt, 0)
		despawn()
	return

func despawn() -> void:
	# Animation?
	#
	#
	queue_free()
	return

func is_moving() -> bool:
	return abs(velocity) > Vector2.ZERO

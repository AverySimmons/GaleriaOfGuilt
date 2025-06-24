extends Area2D

var velocity: Vector2
var explosion_time: float = 1.0
var timer_until_explosion: float = 2.0
var target_location: Vector2

# Z variable for grenade arc
var z: float
var z_speed: float
var z_gravity: float = -200

var spinning: float = 6
var spinning_friction: float = 2

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	position += velocity * delta
	
	rotation += spinning * delta
	spinning -= spinning_friction * delta
	# For the arc
	z_speed += z_gravity * delta
	z += z_speed * delta
	$Sprite2D.position.y = z
	if z <= 0:
		explode()
	pass

func get_thrown(location: Vector2, shot_velocity: Vector2) -> void:
	velocity = shot_velocity
	target_location = Vector2((location.x + randf_range(-10, 10)), location.y + randf_range(-10, 10))
	var distance = (target_location - global_position).length()
	var time = distance / velocity.length()
	z_speed = -0.5 * gravity * time
	return

func explode() -> void:
	return

extends Area2D

var velocity: Vector2
var explosion_time: float = 1.0
var timer_until_explosion: float = 2.0
var target_location: Vector2

# Z variable for grenade arc
var z: float
var z_speed: float
var z_gravity: float = -200

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	position += velocity * delta
	
	# For the arc
	z_speed -= z_gravity * delta
	z += z_speed * delta
	$Sprite2D.position.y = z
	if z <= 0:
		explode()
	pass

func get_thrown() -> void:
	return

func explode() -> void:
	return

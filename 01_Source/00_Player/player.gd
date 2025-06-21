extends CharacterBody2D


@export var top_speed: float = 400
@export var acceleration: float = 700
@export var idle_friction: float = 800


func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	# Movement
	var movement_vector: Vector2 = Input.get_vector("left", "right", "up", "down")
	
	if movement_vector != Vector2.ZERO:
		velocity = velocity.move_toward(movement_vector * top_speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, idle_friction * delta)
	position += velocity * delta
	pass

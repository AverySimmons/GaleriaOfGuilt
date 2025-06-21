extends CharacterBody2D


@export var top_speed: float = 400
@export var acceleration: float = 1000
@export var idle_friction: float = 800
# For handling priority. -1 means left/up, 1 means right/down, 0 means idle
var most_recent_press: Vector2 = Vector2(0, 0)

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	# Movement
	if Input.is_action_just_pressed("left") && most_recent_press.x >= 0:
		most_recent_press.x = -1
	elif Input.is_action_just_pressed("right") && most_recent_press.x <= 0:
		most_recent_press.x = 1
	elif !Input.is_action_pressed("right") && !Input.is_action_pressed("left"):
		most_recent_press.x = 0
	
	if Input.is_action_just_pressed("up") && most_recent_press.y >= 0:
		most_recent_press.y = -1
	elif Input.is_action_just_pressed("down") && most_recent_press.y <= 0:
		most_recent_press.y = 1
	elif !Input.is_action_pressed("up") && !Input.is_action_pressed("down"):
		most_recent_press.y = 0
	
	var movement_vector: Vector2 = most_recent_press.normalized()
	
	if movement_vector != Vector2.ZERO:
		velocity = velocity.move_toward(movement_vector * top_speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, idle_friction * delta)
	position += velocity * delta
	pass

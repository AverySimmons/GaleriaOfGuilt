extends CharacterBody2D

# Velocity stuff
@export var top_speed: float = 250
@export var acceleration: float = 700
@export var idle_friction: float = 600
# For handling priority. -1 means left/up, 1 means right/down, 0 means idle
var most_recent_press: Vector2 = Vector2(0, 0)

# HP stuff
@export var max_hp: float = 100
var current_hp: float

# Blood Bar stuff
@export var bb_max: float = 250
@export var bb_hit: float = 1
@export var bb_kill: float = 5
@export var bb_spd: float = 1.0/250.0
@export var bb_hit_speed: float = 1.0/250.0
@export var bb_timer_time: float = 4
@onready var bb_timer: float = bb_timer_time
@export var bb_to_health: float = 1.0

# Attack stuff
@export var attack_cooldown: float = 0.75
var attack_timer: float = 0


func _ready() -> void:
	current_hp = max_hp
	pass

func _physics_process(delta: float) -> void:
	# Movement
	var movement_vector: Vector2 = get_movement_vector()
	
	if movement_vector != Vector2.ZERO:
		velocity = velocity.move_toward(movement_vector * top_speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, idle_friction * delta)
	position += velocity * delta
	
	# Attacks
	if Input.is_action_just_pressed("main_attack"):
		if attack_timer == 0:
			$blood_swipe.initiate_attack()
			attack_timer = attack_cooldown
		else:
			$blood_swipe.attack_not_ready()
	
	attack_timer = move_toward(attack_timer, 0, delta)
	
	# Blood Bar stuff
	
	
	pass


func get_movement_vector() -> Vector2:
	# Most recent key press overrides movement
	if Input.is_action_just_pressed("left") && most_recent_press.x >= 0:
		most_recent_press.x = -1
	elif Input.is_action_just_pressed("right") && most_recent_press.x <= 0:
		most_recent_press.x = 1
	elif !Input.is_action_pressed("right") && !Input.is_action_pressed("left"):
		most_recent_press.x = 0
	
	if Input.is_action_just_released("left") && Input.is_action_pressed("right"):
		most_recent_press.x = 1
	elif Input.is_action_just_released("right") && Input.is_action_pressed("left"):
		most_recent_press.x = -1
	
	if Input.is_action_just_pressed("up") && most_recent_press.y >= 0:
		most_recent_press.y = -1
	elif Input.is_action_just_pressed("down") && most_recent_press.y <= 0:
		most_recent_press.y = 1
	elif !Input.is_action_pressed("up") && !Input.is_action_pressed("down"):
		most_recent_press.y = 0
	
	# If a key is released, resume the previous direction
	if Input.is_action_just_released("up") && Input.is_action_pressed("down"):
		most_recent_press.y = 1
	elif Input.is_action_just_released("down") && Input.is_action_pressed("up"):
		most_recent_press.y = -1
	
	return most_recent_press.normalized()

func take_damage(amount: float) -> void:
	current_hp -= amount
	return

func heal_damage(amount: float) -> void:
	current_hp += amount
	return

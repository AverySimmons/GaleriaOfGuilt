extends CharacterBody2D

# Velocity stuff
@export var top_speed: float = 250
@export var acceleration: float = top_speed / 0.1 #700
@export var reverse_acceleration: float = top_speed / 0.05 #1400 * 4
@export var idle_friction: float = top_speed / 0.07 #600 * 4
# For handling priority. -1 means left/up, 1 means right/down, 0 means idle
var most_recent_press: Vector2 = Vector2(0, 0)

# HP stuff
@export var max_hp: float = 100
var current_hp: float

# Blood Bar stuff
var blood_bar = 250
@export var bb_max: float = 250
@export var bb_hit: float = 1
@export var bb_kill: float = 5
@export var bb_spd: float = 1.0/250.0
var bb_spd_inc: float = 1.0
@export var bb_hitspd: float = 1.0/500.0
var bb_hitspd_inc: float = 1.0
@export var bb_timer_time: float = 3
@onready var bb_timer: float = bb_timer_time
@export var bb_to_health_ratio: float = 1.0
var dealt_damage_took_damage: bool = false
@export var bb_decrease_rate: float = 10
var bb_decrease: float = 0

# Attack stuff
@export var attack_cooldown: float = 0.75
var actual_attack_cooldown: float = 0
var attack_timer: float = 0
var test_timer = 1

func _ready() -> void:
	current_hp = max_hp
	pass

func _physics_process(delta: float) -> void:
	# Movement
	var movement_vector: Vector2 = get_movement_vector()
	
	if movement_vector != Vector2.ZERO:
		if velocity.normalized().dot(movement_vector) < -0.5:
			velocity = velocity.move_toward(movement_vector * top_speed, reverse_acceleration * delta)
		else: 
			velocity = velocity.move_toward(movement_vector * top_speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, idle_friction * delta)
	position += velocity * delta * bb_spd_inc
	
	# Attacks
	if Input.is_action_just_pressed("main_attack"):
		if attack_timer == 0:
			$blood_swipe.initiate_attack()
			attack_timer = attack_cooldown - bb_hitspd_inc
	
	attack_timer = move_toward(attack_timer, 0, delta)
	
	# Blood Bar stuff
	if dealt_damage_took_damage == false:
		bb_timer = move_toward(bb_timer, 0, delta)
	else:
		bb_timer = bb_timer_time
		bb_decrease = 0
		dealt_damage_took_damage = false
	
	if bb_timer == 0:
		# Visuals?
		#
		#
		
		bb_decrease += bb_decrease_rate * delta
		var heal_amt = blood_bar
		blood_bar = move_toward(blood_bar, 0, bb_decrease * delta)
		heal_amt -= blood_bar
		heal_damage(heal_amt * bb_to_health_ratio)
	
	bb_spd_inc = 1.0 + (blood_bar * bb_spd)
	bb_hitspd_inc = 1.0 - (blood_bar * bb_hitspd)
	
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

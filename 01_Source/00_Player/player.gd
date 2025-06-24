class_name Player
extends CharacterBody2D

@onready var animation_player: AnimationPlayer = $PlayerSpriteAP
@onready var sprite: Sprite2D = $Sprite2D


# Velocity stuff
@export var top_speed: float = 250
@export var acceleration: float = top_speed / 0.1 #700
@export var reverse_acceleration: float = top_speed / 0.05 #1400 * 4
@export var idle_friction: float = top_speed / 0.07 #600 * 4
# For handling priority. -1 means left/up, 1 means right/down, 0 means idle
var most_recent_press: Vector2 = Vector2(0, 0)
var movement_vector: Vector2

var base_velocity := Vector2.ZERO

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
var attack_cooldown_timer: float = 0
var attack_timer: float = 0
var special_ability_timer: float # Relative to current special ability timer in code
var using_attack_or_special_or_dash: bool = false
var current_ability: SpecialAbility = null

var is_dashing: bool = false
var dash_distance: float = 150
var dash_speed: float = 1250
var dash_time: float = dash_distance/dash_speed
var dash_direction: Vector2
var dash_cd: float = 2
var dash_timer: float = 0
var is_invincible: bool = false

func _ready() -> void:
	current_hp = max_hp
	GameData.player = self
	
	# Set special ability to bite
	var bite_scene = preload("res://03_Components/00_Special_Abilities/bite.tscn")
	set_ability(bite_scene)
	#var shotgun_scene = preload("res://03_Components/00_Special_Abilities/shotgun.tscn")
	#set_ability(shotgun_scene)
	#var grenade_scene = preload("res://03_Components/00_Special_Abilities/grenade.tscn")
	#set_ability(grenade_scene)
	pass

func _physics_process(delta: float) -> void:
	# Movement --------------------------------------------------------------
	if !is_dashing:
		movement_vector = get_movement_vector()
		if movement_vector != Vector2.ZERO:
			if base_velocity.normalized().dot(movement_vector) < -0.5:
				base_velocity = base_velocity.move_toward(movement_vector * top_speed, reverse_acceleration * delta)
			else: 
				base_velocity = base_velocity.move_toward(movement_vector * top_speed, acceleration * delta)
		else:
			base_velocity = base_velocity.move_toward(Vector2.ZERO, idle_friction * delta)
		velocity = base_velocity * bb_spd_inc * $blood_swipe.attack_slowdown_actual * current_ability.special_slowdown_actual
	else:
		# In a dash: If it hits a wall, should end the dash
		pass
	move_and_slide()
	
	
	# Attacks ---------------------------------------------------------------
	if Input.is_action_just_pressed("main_attack"):
		if attack_timer == 0 && using_attack_or_special_or_dash == false:
			animation_player.play("slash_left")
			$blood_swipe.initiate_attack()
			attack_timer = attack_cooldown * bb_hitspd_inc
	
	if Input.is_action_just_pressed("special_attack"):
		if special_ability_timer == 0 && using_attack_or_special_or_dash == false:
			animation_player.play("bite_left")
			current_ability.use_ability()
			special_ability_timer = current_ability.cooldown * bb_hitspd_inc
	
	if Input.is_action_just_pressed("dash"):
		if dash_timer == 0 && using_attack_or_special_or_dash == false:
			$Dash.start_dash(dash_speed*bb_spd_inc, dash_distance, movement_vector)
			dash_timer = dash_cd * bb_hitspd_inc
	
	attack_timer = move_toward(attack_timer, 0, delta)
	special_ability_timer = move_toward(special_ability_timer, 0, delta)
	dash_timer = move_toward(dash_timer, 0, delta)
	
	
	# Blood Bar stuff -------------------------------------------------------
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
	
	
	# Animation stuff -------------------------------------------------------
	
	if attack_timer or special_ability_timer: return
	
	## JOEY this is setting the animation player run speed
	## idk how to scale this with speed exactly
	animation_player.speed_scale = 1.0 * bb_spd_inc
	
	if movement_vector == Vector2.ZERO:
		animation_player.play("idle")
	var facing_dir = get_facing_direction()
	
	match facing_dir:
		"right":
			sprite.scale.x = -0.5
			animation_player.play("run_left")
		"left":
			sprite.scale.x = 0.5
			animation_player.play("run_left")
		"down":
			animation_player.play("run_down")
		"up":
			animation_player.play("run_up")
		"idle":
			animation_player.play("idle")
	
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

func get_facing_direction() -> String:
	if most_recent_press.x > 0:
		return "right"
	elif most_recent_press.x < 0:
		return "left"
	elif most_recent_press.y > 0:
		return "down"
	elif most_recent_press.y < 0:
		return "up"
	else:
		return "idle"

func take_damage(amount: float) -> void:
	current_hp = move_toward(current_hp, 0, amount)
	if current_hp <= 0:
		print("Ouch!")
	dealt_damage_took_damage = true
	return

func heal_damage(amount: float) -> void:
	current_hp = move_toward(current_hp, max_hp, amount)
	return

func set_ability(ability) -> void:
	var new_ability = ability.instantiate()
	new_ability.global_position = global_position
	add_child(new_ability)
	if current_ability != null:
		remove_child(current_ability)
		current_ability.queue_free()
	current_ability = new_ability
	return

func is_moving() -> bool:
	return abs(velocity).length() > 0

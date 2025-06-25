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
var blood_bar = 0
@export var bb_max: float = 250
@export var bb_hit: float = 1
var bb_hit_actual: float = 1
var bb_multiplier: float = 1.0
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
var dash_distance: float = 250
var dash_speed: float = 1250
var dash_time: float = dash_distance/dash_speed
var dash_direction: Vector2
var dash_cd: float = 2
var dash_timer: float = 0
var is_invincible: bool = false

var movement_animations = {
	"idle" : null,
	"run_up" : null,
	"run_left" : null,
	"run_down" : null
}

func _ready() -> void:
	current_hp = max_hp
	GameData.player = self
	
	# Set special ability to bite
	var bite_scene = preload("res://03_Components/00_Special_Abilities/bite.tscn")
	set_ability(bite_scene)
	#var shotgun_scene = preload("res://03_Components/00_Special_Abilities/shotgun.tscn")
	#set_ability(shotgun_scene)
	var grenade_scene = preload("res://03_Components/00_Special_Abilities/grenade.tscn")
	set_ability(grenade_scene)
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
		move_and_slide()
	else:
		# In a dash: If it hits a wall, should end the dash
		var distance: Vector2 = velocity * delta
		while distance.length() > 0:
			print(distance)
			var collision = move_and_collide(distance)
			if collision != null:
				var collider = collision.get_collider()
				if collider is TileMap:
					$Dash.end_dash()
					distance = Vector2.ZERO
				elif collider is Enemy:
					# Maybe do something with upgrades?
					distance = collision.get_remainder()
				else:
					distance = Vector2.ZERO
			else:
				break
		
		pass
	
	
	# Attacks ---------------------------------------------------------------
	if Input.is_action_just_pressed("main_attack"):
		if attack_timer == 0 && using_attack_or_special_or_dash == false:
			
			## get direction to mouse, turn it into a word, 
			## then play that animation
			var dir = global_position.direction_to(get_global_mouse_position())
			var facing_dir = name_from_vect_dir(dir)
			facing_dir = update_facing_direction(facing_dir)
			animation_player.play("slash_" + facing_dir)
			
			$blood_swipe.initiate_attack()
			attack_timer = attack_cooldown * bb_hitspd_inc
	
	if Input.is_action_just_pressed("special_attack"):
		if special_ability_timer == 0 && using_attack_or_special_or_dash == false:
			
			## same here as above (blah blah blah repeating code)
			var dir = global_position.direction_to(get_global_mouse_position())
			var facing_dir = name_from_vect_dir(dir)
			facing_dir = update_facing_direction(facing_dir)
			animation_player.play("bite_" + facing_dir)
			
			current_ability.use_ability()
			special_ability_timer = current_ability.cooldown * bb_hitspd_inc
	
	if Input.is_action_just_pressed("dash"):
		if dash_timer == 0 && using_attack_or_special_or_dash == false:
			if movement_vector == Vector2.ZERO:
				movement_vector = Vector2(0, 1)
			var dash_animation: String = "dash_" + update_facing_direction(get_facing_direction())
			animation_player.speed_scale = 1.0 * bb_spd_inc
			animation_player.play(dash_animation)
			
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
	bb_hit_actual = bb_hit * bb_hitspd_inc
	
	# Animation stuff -------------------------------------------------------
	if is_dashing:
		return
	## JOEY this is setting the animation player run speed
	## idk how to scale this with speed exactly
	animation_player.speed_scale = 1.0 * bb_spd_inc
	
	## changed this so that if we are playing an attack animation
	## we dont switch
	if animation_player.is_playing() and \
		animation_player.current_animation not in movement_animations: return
	
	if movement_vector == Vector2.ZERO:
		animation_player.play("idle")
	var facing_dir = get_facing_direction()
	
	facing_dir = update_facing_direction(facing_dir)
	
	if facing_dir == "idle":
		animation_player.play("idle")
	else:
		animation_player.play("run_" + facing_dir)
	
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

## takes the angle of a vector and gives the direction as a string
func name_from_vect_dir(dir: Vector2) -> String:
	var ang = dir.angle()
	if ang <= PI * 0.25 and ang >= -PI * 0.25:
		return "right"
	elif ang < -PI * 0.25 and ang > -PI * 0.75:
		return "up"
	elif ang < PI * 0.75 and ang > PI * 0.25:
		return "down"
	else:
		return "left"

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

## flips the sprite if facing right (or reverts flip if facing left)
func update_facing_direction(facing_dir: String) -> String:
	if facing_dir == "right":
		facing_dir = "left"
		sprite.scale.x = -0.5
	elif facing_dir == "left":
		sprite.scale.x = 0.5
	
	return facing_dir

func take_damage(amount: float) -> void:
	current_hp = move_toward(current_hp, 0, amount)
	print("I got hit!")
	if current_hp <= 0:
		print("I died!")
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

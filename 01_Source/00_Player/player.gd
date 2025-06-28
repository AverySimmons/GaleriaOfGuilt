class_name Player
extends CharacterBody2D

@onready var animation_player: AnimationPlayer = $PlayerSpriteAP
@onready var sprite: Sprite2D = $Sprite2D
@onready var swipe = $blood_swipe

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
@export var swipe_bb_gain: float = 10
@export var special_bb_gain: float = 15
var swipe_bb_actual: float = 1
var special_bb_actual: float = 2
var bb_multiplier: float = 1.0
var bb_multiplier2: float = 1.0 # If you want to know what this is ask me bc tbh idrk anymore
@export var bb_kill: float = 5
@export var bb_spd: float = 1.0/250.0
var bb_spd_inc: float = 1.0
@export var bb_hitspd: float = 1.0/750.0
var bb_hitspd_inc: float = 1.0
@export var bb_timer_time: float = 3
@onready var bb_timer: float = bb_timer_time
@export var bb_to_health_ratio: float = 0.4
var dealt_damage_took_damage: bool = false
@export var bb_decrease_rate: float = 10
var bb_decrease: float = 0
var percentage_to_start_removing_blood_passively: float = 0.6
var passive_blood_loss_amount_at_the_above_percentage: float = 4
var passive_blood_loss_amount_at_max_blood: float = 10
var blood_loss_at_max: float = 0.3
var burst_time: float = 5
var burst_timer: float = 0
var burst_mult: float = 1.3
var burst_mult_actual: float = 1.0

signal burst_begin
signal burst_end

# Attack stuff
@export var attack_cooldown: float = 0.75
var actual_hitspd: float = attack_cooldown
var attack_cooldown_timer: float = 0
var attack_timer: float = 0
var special_ability_timer: float # Relative to current special ability timer in code
var using_attack_or_special_or_dash: bool = false
var current_ability: SpecialAbility = null
var current_ability_name: int = 1
var current_ability_scene = null

# Dash stuff
var is_dashing: bool = false
var dash_distance: float = 200
var dash_speed: float = 1250
var dash_time: float = dash_distance/dash_speed
var dash_direction: Vector2
var dash_cd: float = 1.5
var dash_timer: float = 0
var is_invincible: bool = false
var dashed_into_enemies: Dictionary

# Levelup stuff ----------------------------------------
var level: int = 0
var exp_needed: float = 100
var current_exp: float = 0
var exp_mult: float = 1.0

# Upgrade stuff ----------------------------------------
var dash_blood_cost: float = 0
var swipe_blood_cost: float = 0
var special_blood_cost: float = 0

var upgrade_swipe_mult: float = 1.0

var spcd_increase: float = 1.0
var sp_blood_mult: float = 1.0

var hp_regen: float = 3
var baseline_speed: float = 0

var dash_charges: int = 1
var dash_charges_amt: int = 1

var movement_animations = {
	"idle" : null,
	"run_up" : null,
	"run_left" : null,
	"run_down" : null
}

func _ready() -> void:
	current_hp = max_hp
	GameData.player = self
	SignalBus.death.connect(gain_exp)
	# Set special ability to bite
	var bite_scene = preload("res://03_Components/00_Special_Abilities/bite.tscn")
	set_ability(bite_scene)
	#var shotgun_scene = preload("res://03_Components/00_Special_Abilities/shotgun.tscn")
	#set_ability(shotgun_scene)
	#var grenade_scene = preload("res://03_Components/00_Special_Abilities/grenade.tscn")
	#set_ability(grenade_scene)
	#print(UpgradeData.selectable_upgrades.size())
	UpgradeData.selectable_upgrades[19].choose_upgrade()
	#print(UpgradeData.selectable_upgrades.size())
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
		if UpgradeData.upgrades_gained[UpgradeData.MORE_SPD_LESS_BG]:
			velocity += baseline_speed * movement_vector * $blood_swipe.attack_slowdown_actual * current_ability.special_slowdown_actual
		move_and_slide()
	else:
		var collided_enemies = $DashChecker.get_overlapping_areas()
		for area in collided_enemies:
			var enemy = area.owner
			if enemy is Enemy && !dashed_into_enemies.has(enemy):
				# Upgrade stuff?
				if UpgradeData.upgrades_gained[UpgradeData.DASH_DAMAGE]:
					enemy.take_damage(swipe.damage, 0.2, 0)
				if UpgradeData.upgrades_gained[UpgradeData.MARK_DASH]:
					enemy.get_marked()
				if UpgradeData.upgrades_gained[UpgradeData.DASH_DISTANCE_BLOOD_GAIN]:
					if !(blood_bar >= bb_max):
						blood_bar = move_toward(blood_bar, bb_max, 15*bb_multiplier)
						SignalBus.bb_change.emit()
					
				dashed_into_enemies[enemy] = null
		# In a dash: If it hits a wall, should end the dash
		var distance: Vector2 = velocity * delta
		while distance.length() > 0:
			var collision = move_and_collide(distance)
			if collision != null:
				var collider = collision.get_collider()
				if collider is TileMap:
					$Dash.end_dash()
					distance = Vector2.ZERO
				elif collider is Enemy:
					distance = collision.get_remainder()
				else:
					distance = Vector2.ZERO
			else:
				break
		
		pass
	

	
	
	# Attacks ---------------------------------------------------------------
	if Input.is_action_just_pressed("main_attack"):
		if attack_timer == 0 && using_attack_or_special_or_dash == false:
			if UpgradeData.upgrades_gained[UpgradeData.COSTS_BLOOD_MORE_DMG] && blood_bar-swipe_blood_cost>=0:
				blood_bar -= swipe_blood_cost
				SignalBus.bb_change.emit()
			## get direction to mouse, turn it into a word, 
			## then play that animation
			var dir = global_position.direction_to(get_global_mouse_position())
			var facing_dir = name_from_vect_dir(dir)
			facing_dir = update_facing_direction(facing_dir)
			animation_player.speed_scale /= bb_hitspd_inc
			print(animation_player.speed_scale)
			print(attack_cooldown, attack_cooldown*bb_hitspd_inc)
			animation_player.play("slash_" + facing_dir)
			
			$blood_swipe.initiate_attack(upgrade_swipe_mult)
			attack_timer = attack_cooldown * bb_hitspd_inc
	
	if Input.is_action_just_pressed("special_attack"):
		if special_ability_timer == 0 && using_attack_or_special_or_dash == false:
			# Sorry this is basically to check just for one upgrade, usually it doesn't matter so completely ignore it
			var guysthiscodesucksbutimrushing: bool = true
			if UpgradeData.upgrades_gained[UpgradeData.SPECIAL_CD_RED_COST_HP]:
				if (current_hp - max_hp/10.0) <= 0:
					guysthiscodesucksbutimrushing = false
				else:
					take_damage(max_hp/10.0)
			## same here as above (blah blah blah repeating code)
			if guysthiscodesucksbutimrushing:
				var dir = global_position.direction_to(get_global_mouse_position())
				var facing_dir = name_from_vect_dir(dir)
				facing_dir = update_facing_direction(facing_dir)
				match current_ability_name:
					0:
						animation_player.play("bite_" + facing_dir)
					1:
						animation_player.play("special_" + facing_dir)
					2:
						animation_player.play("special_" + facing_dir)
			
				current_ability.use_ability()
				special_ability_timer = current_ability.cooldown * bb_hitspd_inc * spcd_increase
	
	if Input.is_action_just_pressed("dash"):
		if dash_charges > 0 && using_attack_or_special_or_dash == false && (blood_bar-dash_blood_cost>=0):
			if movement_vector == Vector2.ZERO:
				movement_vector = Vector2(0, 1)
			var dash_animation: String = "dash_" + update_facing_direction(get_facing_direction())
			animation_player.speed_scale = 1.0 * bb_spd_inc
			animation_player.play(dash_animation)
			
			$Dash.start_dash(dash_speed*bb_spd_inc, dash_distance, movement_vector)
			dash_timer = dash_cd * bb_hitspd_inc
			dash_charges -= 1
			blood_bar -= dash_blood_cost
			if dash_blood_cost != 0:
				SignalBus.bb_change.emit()
	
	attack_timer = move_toward(attack_timer, 0, delta)
	special_ability_timer = move_toward(special_ability_timer, 0, delta)
	dash_timer = move_toward(dash_timer, 0, delta)
	if dash_timer <= 0:
		dash_charges = dash_charges_amt
	
	
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
		SignalBus.bb_change.emit()
		heal_amt -= blood_bar
		if !UpgradeData.upgrades_gained[UpgradeData.HIGH_BLOOD_REGEN]:
			heal_damage(heal_amt * bb_to_health_ratio)
	
	if UpgradeData.upgrades_gained[UpgradeData.HIGH_BLOOD_REGEN] && blood_bar >= 200:
		heal_damage(hp_regen*delta)
	
	if blood_bar == bb_max:
		burst_timer = burst_time
		blood_bar -= blood_bar * blood_loss_at_max
		SignalBus.bb_change.emit()
		bb_multiplier2 *= 0.6
		burst_mult_actual = burst_mult
		burst_begin.emit()
	
	var was_in_burst = burst_timer > 0
	burst_timer = move_toward(burst_timer, 0, delta)
	
	if was_in_burst && burst_timer == 0:
		bb_multiplier2 /= 0.6
		burst_mult_actual = 1.0
		burst_end.emit()
	
	if blood_bar >= bb_max*percentage_to_start_removing_blood_passively:
		var amt_to_lose_passively_yo: float = passive_blood_loss_amount_at_the_above_percentage + ((passive_blood_loss_amount_at_max_blood - passive_blood_loss_amount_at_the_above_percentage) * (blood_bar-bb_max*percentage_to_start_removing_blood_passively)/(bb_max-percentage_to_start_removing_blood_passively*bb_max))
		blood_bar = move_toward(blood_bar, 0, amt_to_lose_passively_yo*delta)
		SignalBus.bb_change.emit()
	bb_spd_inc = 1.0 + (blood_bar * bb_spd)
	bb_hitspd_inc = 1.0 - (blood_bar * bb_hitspd)
	bb_hitspd_inc /= burst_mult_actual
	bb_spd_inc *= burst_mult_actual
	if bb_hitspd_inc <= 0.1:
		bb_hitspd_inc = 0.1
	bb_multiplier = max(bb_multiplier2*bb_hitspd_inc*bb_hitspd_inc, 0.2)
	swipe_bb_actual = swipe_bb_gain * bb_multiplier
	special_bb_actual = special_bb_gain * bb_multiplier
	
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
	if is_invincible:
		return
	current_hp = move_toward(current_hp, 0, amount)
	if current_hp <= 0:
		# death
		pass
	dealt_damage_took_damage = true
	SignalBus.hp_change.emit()
	return

func heal_damage(amount: float) -> void:
	current_hp = move_toward(current_hp, max_hp, amount)
	SignalBus.hp_change.emit()
	return

func gain_blood(attack_type: String, mult: float, enemy: Enemy) -> void:
	if blood_bar >= bb_max:
		return
	if enemy != null:
		if enemy.is_marked:
			mult = mult * 2.5
	var gain: float = swipe_bb_actual
	match attack_type:
		"swipe": 
			gain = swipe_bb_actual
		"special":
			gain = special_bb_actual * sp_blood_mult
	blood_bar = move_toward(blood_bar, bb_max, gain*mult)
	SignalBus.bb_change.emit()
	return

func gain_blood_other(amount: float) -> void:
	if blood_bar >= bb_max:
		return
	blood_bar = move_toward(blood_bar, bb_max, amount)
	SignalBus.bb_change.emit()

func set_ability(ability) -> void:
	var new_ability = ability.instantiate()
	add_child(new_ability)
	new_ability.global_position = global_position
	if current_ability != null:
		remove_child(current_ability)
		current_ability.queue_free()
	current_ability = new_ability
	return

func is_moving() -> bool:
	return abs(velocity).length() > 0

func get_signal_upgrade(upgrade_name: String) -> void:
	match upgrade_name:
		"kill_blood_gain":
			SignalBus.death.connect(kill_gain_blood)
		"kill_lower_special_cd":
			SignalBus.death.connect(kill_lower_spcd)
	return

#Upgrade stuff
func kill_gain_blood(enemy: Enemy) -> void:
	if blood_bar >= bb_max:
		return
	var amount: float = 0
	match enemy.type:
		"Lizard":
			amount = 15
		"Worm":
			amount = 10
		"Locust":
			amount = 5
	blood_bar = move_toward(blood_bar, bb_max, amount*bb_multiplier)
	SignalBus.bb_change.emit()
	return

func kill_lower_spcd() -> void:
	if special_ability_timer >= 0:
		special_ability_timer = move_toward(special_ability_timer, 0, (current_ability.cooldown * bb_hitspd_inc * spcd_increase)/3)
	return

# Level stuff
func gain_exp(enemy: Enemy) -> void:
	var amount: float = 0
	match enemy.type:
		"Lizard":
			amount = 8
		"Worm":
			amount = 6
		"Locust":
			amount = 4
	current_exp = move_toward(current_exp, exp_needed, amount*exp_mult)
	if current_exp >= exp_needed:
		SignalBus.levelup.emit()
		exp_needed += 50*level
		level += 1
		current_exp = 0
	SignalBus.gained_exp.emit()
	return

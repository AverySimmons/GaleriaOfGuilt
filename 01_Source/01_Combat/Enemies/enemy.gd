class_name Enemy
extends CharacterBody2D

@onready var sprite = $Sprite2D

@export var move_speed: float = 100

@export var hp_max: float = 10 #change this
@export var type: String = '' #enemy type. How will this be used, is it declared in some spawn_enemy function?
@export var flinch_guard: float = 0
@export var upgraded: bool = false

@onready var blood_module: Node2D = $BloodModule

var hp
var bullet_node

@onready var lighting_scene = preload("res://03_Components/ball_o_lightning.tscn")

var facing_direction: Vector2 = Vector2.RIGHT
var death_state: bool = false
var movement_type: String = '' #will these be a seperate scene?? 

var undamaged: bool = true
var distance_to_player: float = 1000000

var going_up: bool = false #nearly going straight up
var going_down: bool = false #approximately stright down

var Animations : AnimationPlayer

var level

var player_position: Vector2
@export var shake_length: float = 1
@export var arrow_dist: float = 100
@export var indicator_color: Color = Color("blue")
@export var chase_dist: float = 100
var target_ind
var indicator_node

@onready var hit_sound = $HitSound

# For upgrades:
var is_marked: bool = false
var marked_time: float = 8
var marked_timer: float = marked_time

@onready var upgrade_mark_sprite = $UpgradeMark
@onready var beating_heart_sprite = $BeatingHeart

func _ready() -> void:
	hp = hp_max
	sprite.material.set_shader_parameter("offset_x", randf_range(0,10))
	sprite.material.set_shader_parameter("offset_y", randf_range(0,10))
	#var animation = the specific enemies animation?
	#$AnimatedSprite2D.play(animation)
	
	# For upgrades:
	$DashMark.visible = false
	pass
	
#timers

## I'm switching this to awaiting the death animation !
## var death_timer = 1 #a little delay for the animation to play, is there a better way?

func start_death() -> void:
	if death_state: return
	if $MarkForUpgrade != null:
		$MarkForUpgrade.stop()
	if upgrade_mark_sprite != null:
		upgrade_mark_sprite.visible = false
	if beating_heart_sprite != null:
		beating_heart_sprite.visible = false
	$DashMark.visible = false
	var hurtbox = $Hurtbox
	if hurtbox != null:
		hurtbox.monitorable = false
	death_state = true
	AudioData.play_sound("enemy_death", $DeathSound)
	if target_ind: target_ind.conceal()
	$BTPlayer.process_mode = Node.PROCESS_MODE_DISABLED
	blood_module.enemy_death(global_position)
	await get_tree().physics_frame
	$Animations.play('death')
	if $DeathSound.playing:
		await $DeathSound.finished
	else:
		await $Animations.animation_finished
	SignalBus.death.emit(self)
	call_deferred("queue_free")

func _physics_process(delta: float) -> void:
	if death_state: return
	
	#update distance to player
	if GameData.player:
		distance_to_player = GameData.player.global_position.distance_to(global_position)
	
	#death
	#DEBUG DAMAGE TESTABLE
	#if Input.is_action_just_pressed('take_damage_debug'):
		#mark_for_upgrade()
	
	if hp <= 0:
		if not death_state:
			start_death() #emits signal and plays animation right now
	
	
	## I'm switching all the death timer stuff to waiting for the animation to finish
	#	death_timer -= 1 #how do I make this different for each enemy? does it have to be?
		
	#if death_timer <= 0: #time to die
	#	queue_free()
		
	#MOVEMENT ANIMATIONS
	if velocity.length() > 1:
		#print('movement animations')
		select_movement_animations()
		

	
	# For upgrades:
	if is_marked:
		marked_timer = move_toward(marked_timer, 0, delta)
		if marked_timer <= 0:
			marked_timer = marked_time
			is_marked = false
			$DashMark.visible = false
	
	#right - 0
	#-pi/4 topside 45
	#pi/4 bot side 45

func take_damage(damage: float, flinch: float, knockback: float) -> void:
	if death_state: return
	if is_marked: damage *= 2
	hp -= damage
	AudioData.play_sound("enemy_hit", hit_sound)
	sprite.material.set_shader_parameter("blood_intensity", 1. - hp / hp_max)
	$HitFlash.reset_section()
	$HitFlash.play('hit_flash') #this always happens
	if undamaged:
		undamaged = false
	
	#check if the flinch duration is gonna flinch the enemy
	var flinch_dur = flinch - flinch_guard
	if flinch_dur <= 0:
		return
	#this will proceed only if flinch_dur > 0
	velocity = Vector2.ZERO
	var btplayer := get_node_or_null(^"BTPlayer") as BTPlayer
	if btplayer:
		btplayer.set_active(false)
	
	$Animations.play('hurt')
	await get_tree().create_timer(flinch_dur, false).timeout #wait for flinch time
	if btplayer and hp >= 1:
		btplayer.restart()
	
	
	
	# Flash red somehow #sorry joey I'm doing white instead
	# Flinch for amount of time in flinch - Brian how do this?
	return
	
func select_movement_animations():
	if facing_direction.angle() > -3/4. * PI && facing_direction.angle() < -1/4. * PI: #going hard upward
		going_up = true
	else: 
		going_up = false
	
	if facing_direction.angle() > 1/4. * PI && facing_direction.angle() < 3/4. * PI: #going hard downward
		going_down = true
	else: 
		going_down = false
	
	if going_up:
		$Animations.play('move_up')
	elif going_down:
		$Animations.play('move_down')
	elif facing_direction.x > 0: #going right
		if sprite.scale.x < 0:
			sprite.scale.x *= -1
		$Animations.play('walk')
	else: #going left
		if sprite.scale.x > 0:
			sprite.scale.x *= -1
		$Animations.play('walk')
		

func get_marked() -> void:
	is_marked = true
	marked_timer = marked_time
	$DashMark.visible = true
	return
	
func mark_for_upgrade() -> void:
	$MarkForUpgrade.play('upgrade_mark')
	await get_tree().create_timer(4, false).timeout
	
	
	velocity = Vector2.ZERO
	var btplayer := get_node_or_null(^"BTPlayer") as BTPlayer
	if btplayer:
		btplayer.set_active(false)
	
	if !is_inside_tree():
		return
	await get_tree().create_timer(0.5, false).timeout
	if death_state:
		return
	level.upgrade_enemy(self)

class_name Enemy
extends CharacterBody2D

@onready var sprite = $Sprite2D

@export var move_speed: float = 100

@export var hp: float = 10 #change this
@export var type: String = '' #enemy type. How will this be used, is it declared in some spawn_enemy function?
@export var flinch_guard: float = 0

@onready var blood_module: Node2D = $BloodModule

var facing_direction: Vector2 = Vector2.RIGHT
var death_state: bool = false
var movement_type: String = '' #will these be a seperate scene?? 

var undamaged: bool = true
var distance_to_player: float = 1000000

var going_up: bool = false #nearly going straight up
var going_down: bool = false #approximately stright down

var Animations : AnimationPlayer

var level: Level

var player_position: Vector2
@export var shake_length: float = 1
@export var arrow_dist: float = 100
@export var indicator_color: Color = Color("blue")
var target_ind

# For upgrades:
var is_marked: bool = false
var marked_time: float = 3
var marked_timer: float = marked_time

func _ready() -> void:
	
	#var animation = the specific enemies animation?
	#$AnimatedSprite2D.play(animation)
	
	# For upgrades:
	$DashMark.visible = false
	pass
	
#timers

## I'm switching this to awaiting the death animation !
## var death_timer = 1 #a little delay for the animation to play, is there a better way?

func start_death() -> void:
	if target_ind: target_ind.conceal()
	death_state = true
	$BTPlayer.process_mode = Node.PROCESS_MODE_DISABLED
	SignalBus.death.emit(self)
	blood_module.enemy_death(global_position)
	$Animations.play('death')
	await $Animations.animation_finished
	call_deferred("queue_free")

func _physics_process(delta: float) -> void:
	if death_state: return
	
	#update distance to player
	if GameData.player:
		distance_to_player = GameData.player.global_position.distance_to(global_position)
	
	#death
	#DEBUG DAMAGE TESTABLE
	if Input.is_action_just_pressed('take_damage_debug'):
		take_damage(1, 0.5, 0) #take 1 damage and flinch for a second
	
	if hp <= 0:
		if not death_state:
			start_death() #emits signal and plays animation right now
	
	
	## I'm switching all the death timer stuff to waiting for the animation to finish
	##	death_timer -= 1 #how do I make this different for each enemy? does it have to be?
		
	##if death_timer <= 0: #time to die
	##	queue_free()
		
	#MOVEMENT ANIMATIONS
	if velocity.length() > 1:
		#print('movement animations')
		select_movement_animations()
		
	#deal damage to player
	var overlapping_areas = $Hitbox.get_overlapping_areas()
	if overlapping_areas:
		var player : Player = overlapping_areas[0].owner
		player.take_damage(10)
	
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
	hp -= damage
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
	await get_tree().create_timer(flinch_dur).timeout #wait for flinch time
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

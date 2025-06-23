class_name Enemy
extends CharacterBody2D

@export var move_speed: float = 100

@export var hp: float = 10 #change this
@export var type: String = '' #enemy type. How will this be used, is it declared in some spawn_enemy function?
@export var flinch_guard: float = 0

var facing_direction: Vector2 = Vector2.RIGHT
var death_state: bool = false
var movement_type: String = '' #will these be a seperate scene?? 


func _ready() -> void:
	
	#var animation = the specific enemies animation?
	#$AnimatedSprite2D.play(animation)
	pass
	
#timers
var death_timer = 1 #a little delay for the animation to play, is there a better way?

func start_death() -> void:
	death_state = true
	#emit_signal(enemy_killed)
	#start.animation('death')

func _physics_process(delta: float) -> void:
	#death
	if Input.is_action_just_pressed('take_damage_debug'):
		take_damage(1, 1) #take 1 damage and flinch for a second
	
	if hp <= 0:
		if not death_state:
			start_death() #emits signal and plays animation right now
		death_timer -= 1 #how do I make this different for each enemy? does it have to be?
		
	if death_timer <= 0: #time to die
		queue_free()

func take_damage(damage: float, flinch: float) -> void:
	hp -= damage
	
	$HitFlash.play('hit_flash')
	# Flash red somehow #sorry joey I'm doing white instead
	# Flinch for amount of time in flinch - Brian how do this?
	return

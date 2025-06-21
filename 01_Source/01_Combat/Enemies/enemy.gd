class_name Enemy
extends Area2D

var hp: float = 0
var type: String = '' #enemy type. How will this be used, is it declared in some spawn_enemy function?
var death_state: bool = false
var movement_type: String = '' #will these be a seperate scene?? 

func _ready() -> void:
	$AnimatedSprite2D.play('WormDevWalk')
	
#timers
var death_timer = 1 #a little delay for the animation to play, is there a better way?

func start_death() -> void:
	death_state = true
	#emit_signal(enemy_killed)
	#start.animation('death')
	

func _physics_process(delta: float) -> void:
	#death
	if hp <= 0:
		if not death_state:
			start_death() #emits signal and plays animation right now
		death_timer -= 1 #how do I make this different for each enemy? does it have to be?
		
	if death_timer <= 0: #time to die
		queue_free()

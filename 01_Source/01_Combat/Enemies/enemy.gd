class_name Enemy
extends Node2D

var hp: float = 0
var type: String = ''
var death_state: bool = false


#timers
var death_timer = 1 #a little delay for the animation to play, is there a better way?

func start_death() -> void:
	death_state = true
	emit_signal(enemy_killed)
	start.animation('death')
	

func _physics_process(delta: float) -> void:
	#death
	if hp <= 0:
		if not death_state:
			start_death() #emits signal and plays animation right now
		death_timer -= 1 #how do I make this different for each enemy? does it have to be?
		
	if death_timer <= 0: #time to die
		queue_free()

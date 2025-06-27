@tool
extends BTAction

var enemy : Enemy

var active_time: float 
var active_timer: float
## variables at the top

func _generate_name() -> String:
	return 'Unfinished, do not use this'
	
func _setup() -> void:
	enemy = agent as Enemy
	active_timer = 0
	active_time = 0.5
	
func _enter() -> void:
	pass
	
func _tick(delta: float) -> Status:
	if active_timer >= active_time:
		active_timer = 0
		return SUCCESS
	
	#var ball_o_lightning = enemy.ball_o_lightning.animation_player
	#ball_o_lightning.play('ball_o_lightning_damaging')
	
	
	active_timer += delta
	
	return RUNNING
	
## think about helper functions down here

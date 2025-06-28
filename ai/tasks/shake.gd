@tool
extends BTAction

var accelerable_shake_intensity: float 
var baseline_shake_intensity: float 
var actual_shake_intensity : float

var target_node : CharacterBody2D
var shaking_time: float

var start_pos: Vector2
var shadow_start_pos: Vector2

var enemy : Enemy

## variables at the top

func _generate_name() -> String:
	return 'shake in anticipation for attack'
	
func _setup() -> void:
	enemy = agent as Enemy
	
	accelerable_shake_intensity = 6
	baseline_shake_intensity = 0.8
	
	
	
	
func _enter() -> void:
	target_node = enemy
	shaking_time = 0
	
	## store the sprite position at start (will be restored on exit)
	start_pos = enemy.sprite.global_position

func _exit() -> void:
	enemy.sprite.global_position = start_pos

func _tick(delta: float) -> Status:
	#return to default position
	
	## I changed this to reseting on exit
	# target_node.get_node("Sprite2D").global_position = target_node.global_position
	
	if shaking_time >= 1: #finish
		
		return SUCCESS
	
	#shake
	actual_shake_intensity = baseline_shake_intensity + (accelerable_shake_intensity * (shaking_time))
	var shake_offset: Vector2 = Vector2(randf_range(-actual_shake_intensity, actual_shake_intensity),
										randf_range(-actual_shake_intensity, actual_shake_intensity))
	target_node.get_node("Sprite2D").position += shake_offset
	target_node.get_node("Shadow").position += shake_offset
	
	shaking_time += delta
	
	return RUNNING
	
## think about helper functions down here

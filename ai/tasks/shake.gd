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

var has_locked_dir = false

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
	has_locked_dir = false
	enemy.target_ind = enemy.level.spawn_arrow(0.5, 64, enemy.indicator_color)
	
	## store the sprite position at start (will be restored on exit)
	start_pos = enemy.sprite.global_position

func _exit() -> void:
	enemy.sprite.global_position = start_pos
	enemy.target_ind.conceal()

func _tick(delta: float) -> Status:
	#return to default position
	
	if not has_locked_dir:
		var player_vel = GameData.player.velocity
		var player_pos = GameData.player.global_position
		enemy.player_position = player_pos + player_vel / enemy.global_position.distance_to(player_pos) * 100
		var player_dir = enemy.global_position.direction_to(enemy.player_position)
		var arrow_point = enemy.global_position + player_dir * enemy.arrow_dist * shaking_time / enemy.shake_length / 0.8
		enemy.target_ind.update(enemy.global_position, arrow_point)
	
	## I changed this to reseting on exit
	# target_node.get_node("Sprite2D").global_position = target_node.global_position
	
	if shaking_time >= enemy.shake_length * 0.8:
		has_locked_dir = true
	
	if shaking_time >= enemy.shake_length: #finish
		
		return SUCCESS
	
	#shake
	actual_shake_intensity = baseline_shake_intensity + (accelerable_shake_intensity * (shaking_time))
	var shake_offset: Vector2 = Vector2(randf_range(-actual_shake_intensity, actual_shake_intensity),
										randf_range(-actual_shake_intensity, actual_shake_intensity))
	target_node.get_node("Sprite2D").global_position = start_pos + shake_offset
	
	shaking_time += delta
	
	return RUNNING
	
## think about helper functions down here

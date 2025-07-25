@tool
extends BTAction

var enemy : Enemy

var find_player_timer : float

var dash_duration : float

var dash_direction: Vector2

var sound_effect

## variables at the top

func _generate_name() -> String:
	return 'charge through the player location'
	
func _setup() -> void:
	find_player_timer = 0.1
	dash_duration = 0
	enemy = agent as Enemy
	sound_effect = agent.get_node("LocustAttack")
	
	
func _enter() -> void:
	enemy.hurtbox.monitoring = true
	dash_duration = 0
	find_player_timer = 0.1
	## I'm changing this slightly so that the dash is towards a location
	## picked in shake
	dash_direction = enemy.global_position.direction_to(enemy.player_position)
	
	
	#var next_path = enemy.navigation.get_next_path_position()
	#var move_direction = enemy.global_position.direction_to(next_path)
	#var new_velocity = move_direction * enemy.move_speed * 10
	
	AudioData.play_sound("locust_attack", sound_effect)
	enemy.velocity = dash_direction * enemy.move_speed * 7.7
	enemy.facing_direction = enemy.velocity.normalized()
	
	
	#enemy.velocity = new_velocity
	
func _tick(delta: float) -> Status:
	
	
	var collided = move()
	#stop dash if traveled far enough or 
	dash_duration += delta
	if dash_duration >= 0.65 or collided:
		dash_duration = 0
		return SUCCESS
	
	#if find_player_timer <= 0:
		#check_path()
		#find_player_timer = 0.5
		
	
	#find_player_timer -= delta
	
	return RUNNING
	
func _exit() -> void:
	enemy.hurtbox.monitoring = false
	find_player_timer = 0.1
	enemy.velocity = Vector2.ZERO 

## think about helper functions down here

func move() -> bool:
	return enemy.move_and_slide()

func check_path() -> void:
	
	enemy.navigation.target_position = GameData.player.global_position

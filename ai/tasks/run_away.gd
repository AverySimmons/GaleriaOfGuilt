@tool
extends BTAction

var enemy : Enemy

var find_player_timer : float

## variables at the top

func _generate_name() -> String:
	return 'run from the player'
	
func _setup() -> void:
	find_player_timer = 0.1
	enemy = agent as Enemy
	
func _enter() -> void:
	pass
	
func _tick(delta: float) -> Status:
	
	#if not agent.navigation.is_navigation_finished():
	move()
		
	if find_player_timer <= 0:
		check_path()
		find_player_timer = 0.1
		
	
	find_player_timer -= delta
	
	return RUNNING
	
func _exit() -> void:
	enemy.velocity = Vector2.ZERO 

## think about helper functions down here

func move() -> void:
	var next_path = enemy.navigation.get_next_path_position()
	var move_direction = enemy.global_position.direction_to(next_path)
	var new_velocity = move_direction * enemy.move_speed * -1 #this should invert the direction?
	
	enemy.facing_direction = move_direction * -1 #THIS COULD BE RANDOMIZED A LITTLE
	
	enemy.velocity = new_velocity
	
	enemy.move_and_slide()

func check_path() -> void:
	
	enemy.navigation.target_position = GameData.player.global_position
	

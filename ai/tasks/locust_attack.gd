@tool
extends BTAction

var enemy : Enemy

var find_player_timer : float

var dash_duration : float

## variables at the top

func _generate_name() -> String:
	return 'charge through the player location'
	
func _setup() -> void:
	find_player_timer = 0.1
	dash_duration = 0
	enemy = agent as Enemy
	
	
func _enter() -> void:
	var next_path = enemy.navigation.get_next_path_position()
	var move_direction = enemy.global_position.direction_to(next_path)
	var new_velocity = move_direction * enemy.move_speed * 10
	
	enemy.facing_direction = move_direction
	
	enemy.velocity = new_velocity
	
func _tick(delta: float) -> Status:
	
	
	var collided = move()
	#stop dash if traveled far enough or 
	dash_duration += delta
	if dash_duration >= 0.65 or collided:
		dash_duration = 0
		return SUCCESS
		
	if find_player_timer <= 0:
		check_path()
		find_player_timer = 0.5
		
	
	find_player_timer -= delta
	
	return RUNNING
	
func _exit() -> void:
	enemy.velocity = Vector2.ZERO 

## think about helper functions down here

func move() -> bool:
	
	
	return enemy.move_and_slide()

func check_path() -> void:
	
	enemy.navigation.target_position = GameData.player.global_position

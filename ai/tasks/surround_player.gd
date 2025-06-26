@tool
extends BTAction

var enemy : Enemy

var find_player_timer : float

## variables at the top

func _generate_name() -> String:
	return 'navigate to a position medium range from the player'
	
func _setup() -> void:
	find_player_timer = 0.1
	enemy = agent as Enemy
	
func _enter() -> void:
	pass
	
func _tick(delta: float) -> Status:
	var direction_to_player = enemy.global_position.direction_to(GameData.player.global_position)
	
	if agent.distance_to_player < 300 and agent.distance_to_player > 200 :
		
		if GameData.player.global_position.y > enemy.global_position.y and \
				direction_to_player.angle() > 1/4. * PI && direction_to_player.angle() < 3/4. * PI: #player underneath
			if enemy.sprite.scale.y < 0:
				enemy.sprite.scale.y *= -1
				enemy.going_up = false
				enemy.going_down = true
		elif GameData.player.global_position.y < enemy.global_position.y and \
				direction_to_player.angle() > -3/4. * PI && direction_to_player.angle() < -1/4. * PI: #player up
			if enemy.sprite.scale.y > 0:
				enemy.sprite.scale.y *= -1
				enemy.going_up = true
				enemy.going_down = false
		
		print('navigation finished')
		return SUCCESS
		
	move()
		
	if find_player_timer <= 0:
		check_path()
		find_player_timer = 0.1
		
	
	find_player_timer -= delta
	
	#flip sprite veritcally
	if enemy.going_up:
		if enemy.sprite.scale.y > 0: #facing down
			enemy.sprite.scale.y *= -1
			enemy.going_up = false
			enemy.going_down = true
			
	elif enemy.going_down:
		if enemy.sprite.scale.y < 0:
			enemy.sprite.scale.y *= -1
			enemy.going_up = true
			enemy.going_down = false
	else: #not going up or down
		if enemy.sprite.scale.y < 0:
			enemy.sprite.scale.y *= -1
			enemy.going_up = true
			enemy.going_down = false
	
	return RUNNING
	
func _exit() -> void:
	enemy.velocity = Vector2.ZERO 

## think about helper functions down here

func move() -> void:
	
	if agent.distance_to_player > 300:
		var next_path = enemy.navigation.get_next_path_position()
		var move_direction = enemy.global_position.direction_to(next_path)
		var new_velocity = move_direction * enemy.move_speed
	
		enemy.facing_direction = move_direction
	
		enemy.velocity = new_velocity
	
		enemy.move_and_slide()
	else: #when locust is too close to player
		var next_path = enemy.navigation.get_next_path_position()
		var move_direction = enemy.global_position.direction_to(next_path)
		var new_velocity = move_direction * enemy.move_speed * -1 #this should invert the direction?
	
		enemy.facing_direction = move_direction * -1 #THIS COULD BE RANDOMIZED A LITTLE
	
		enemy.velocity = new_velocity
	
		enemy.move_and_slide()
		
		#
		#if enemy.going_up:
			#if enemy.sprite.scale.y > 0: #facing down
				#enemy.sprite.scale.y *= -1
				#enemy.going_up = false
				#enemy.going_down = true
			#
		#elif enemy.going_down:
			#if enemy.sprite.scale.y < 0:
				#enemy.sprite.scale.y *= -1
				#enemy.going_up = true
				#enemy.going_down = false
		#else: #not going up or down
			#if enemy.sprite.scale.y < 0:
				#enemy.sprite.scale.y *= -1
		

func check_path() -> void:
	
	enemy.navigation.target_position = GameData.player.global_position

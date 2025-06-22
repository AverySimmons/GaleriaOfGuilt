@tool
extends BTAction


@export var max_dist : float = 300.0
@export var min_dist : float = 150.0

var rng : RandomNumberGenerator

func _generate_name() -> String:
	return 'Navigate to a random nearby point'

func _setup() -> void:
	rng = RandomNumberGenerator.new()
	
func _enter() -> void:
	agent.navigation.target_position = pick_destination()
	print(agent.navigation.target_position)
	
func _tick(delta: float) -> Status:
	if agent.navigation.is_navigation_finished():
		return SUCCESS
	
	if not agent.navigation.is_target_reachable():
		return FAILURE
	
	move()
	
	return RUNNING
	
func pick_destination() -> Vector2: #this also flips the sprite
	var offset1 = rng.randf_range(min_dist, max_dist) #if the point is illegal, reroll?
	var offset2 = rng.randf_range(min_dist, max_dist)
	
	offset1 *= [-1, 1].pick_random()
	offset2 *= [-1, 1].pick_random()
	#var offset = 250
	var new_destination = Vector2(agent.global_position.x + offset1, agent.global_position.y + offset2)
	
	#flip sprite
	if agent.global_position.x < new_destination.x: #target is right of the enemy
		if agent.sprite.scale.x == -1:
			agent.sprite.scale.x = 1
	else: #reached when the target location is left of the enemy
		if agent.sprite.scale.x == 1:
			agent.sprite.scale.x = -1
	
	return new_destination
	
func move():
	var next_path = agent.navigation.get_next_path_position()
	var move_direction = agent.global_position.direction_to(next_path)
	var new_velocity = move_direction * agent.move_speed
	
	agent.velocity = new_velocity
	agent.move_and_slide()
	
	

@tool
extends BTAction

var enemy : Enemy
## variables at the top

var timer
var strike_num

var strike_array: Array[Vector2]
var strike_vel_array: Array[Vector2]
var last_strike_array: Array[Vector2]

func _generate_name() -> String:
	return 'Spawn lightning'
	
func _setup() -> void:
	enemy = agent as Enemy
	
func _enter() -> void:
	timer = 2
	strike_num = 3
	strike_array = []
	strike_vel_array = []
	for i in strike_num:
		strike_array.push_back(enemy.global_position)
		last_strike_array.push_back(enemy.global_position)
		var ang_to_player = enemy.global_position.angle_to_point(GameData.player.global_position)
		strike_vel_array.push_back(Vector2.from_angle(randfn(ang_to_player+PI, PI / 3.)) * randf_range(1500, 2000))
	

func _tick(delta: float) -> Status:
	
	for i in strike_num:
		strike_array[i] += strike_vel_array[i] * delta
		var player_dir = strike_array[i].direction_to(GameData.player.global_position)
		strike_vel_array[i] += player_dir * 2500 * delta
		
		if strike_array[i].distance_to(last_strike_array[i]) > 50:
			last_strike_array[i] = strike_array[i]
			spawn_lighting(strike_array[i])
	
	timer -= delta
	if timer <= 0:
		return SUCCESS
	
	return RUNNING

## think about helper functions down here

func spawn_lighting(pos):
	var new_lightning = enemy.lighting_scene.instantiate()
	new_lightning.global_position = pos
	enemy.indicator_node.add_child(new_lightning)

@tool
extends BTAction

var enemy : Enemy

var active_time: float 
var active_timer: float
## variables at the top

func _generate_name() -> String:
	return 'Spawn lightning'
	
func _setup() -> void:
	enemy = agent as Enemy
	active_timer = 0
	active_time = 0.8
	
func _enter() -> void:
	var new_lightning = enemy.lighting_scene.instantiate()
	new_lightning.global_position = GameData.player.global_position
	new_lightning.global_position += Vector2.from_angle(randf_range(0,TAU)) * 40
	enemy.indicator_node.add_child(new_lightning)

func _tick(delta: float) -> Status:
	return SUCCESS
	
	if active_timer >= active_time:
		active_timer = 0
		return SUCCESS
	
	#var ball_o_lightning = enemy.ball_o_lightning.animation_player
	#ball_o_lightning.play('ball_o_lightning_damaging')
	
	
	active_timer += delta
	
	return RUNNING
	
## think about helper functions down here

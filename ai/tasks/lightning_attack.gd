@tool
extends BTAction

var enemy : Enemy
## variables at the top

var target_pos
var timer
var it

func _generate_name() -> String:
	return 'Spawn lightning'
	
func _setup() -> void:
	enemy = agent as Enemy
	
func _enter() -> void:
	target_pos = GameData.player.global_position
	timer = 0
	it = 0

func _tick(delta: float) -> Status:
	timer -= delta
	if timer <= 0:
		timer += 0.1
		spawn_circle()
		it += 1
		if it >= 4:
			return SUCCESS
	
	return RUNNING

## think about helper functions down here

func spawn_circle():
	AudioData.play_sound("lightning_charge", enemy.get_node("ExplodeSound"))
	var cur_rot = randf() * TAU
	var size = 1 + it * 3
	for i in size:
		var offset = Vector2.from_angle(cur_rot) * it * 80
		spawn_lighting(target_pos + offset)
		cur_rot += TAU / float(size)

func spawn_lighting(pos):
	var new_lightning = enemy.lighting_scene.instantiate()
	new_lightning.global_position = pos
	enemy.indicator_node.add_child(new_lightning)

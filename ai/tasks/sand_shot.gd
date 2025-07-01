@tool
extends BTAction

var sand_proj_scene : PackedScene = preload("res://01_Source/01_Combat/Enemies/Projectiles/sand_projectile.tscn")

@export var proj_speed : float = 0 #does this need to be in setup?

var mouth_pos : Vector2

var sound

## variables at the top

func _generate_name() -> String:
	return 'Shoot sand projectile at the player'
	
func _setup() -> void:
	sound = agent.get_node("SandShotSound")
	pass
	
func _enter() -> void:
	mouth_pos = agent.mouth_pos.global_position
	
	
	#if !agent.bullet_node:
		#return
	var sand_proj = sand_proj_scene.instantiate()
	AudioData.play_sound("sand_shot", sound)
	var dir = mouth_pos.direction_to(agent.player_position)
	sand_proj.velocity = dir * 1250
	sand_proj.global_position = mouth_pos
	
	agent.bullet_node.add_child(sand_proj)
	
	
	
func _tick(delta: float) -> Status:
	
	
	
	return SUCCESS
	
## think about helper functions down here

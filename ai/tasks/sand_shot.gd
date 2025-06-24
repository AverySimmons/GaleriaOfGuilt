@tool
extends BTAction

var sand_proj_scene : PackedScene = preload("res://01_Source/01_Combat/Enemies/Projectiles/sand_projectile.tscn")

@export var proj_speed : float = 0 #does this need to be in setup?

## variables at the top

func _generate_name() -> String:
	return 'Shoot sand projectile at the player'
	
func _setup() -> void:
	pass
	
func _enter() -> void:
	#if !agent.bullet_node:
		#return
	var sand_proj = sand_proj_scene.instantiate()
	var dir = agent.global_position.direction_to(GameData.player.global_position)
	sand_proj.velocity = dir * 400
	agent.add_child(sand_proj)
	
	
	
func _tick(delta: float) -> Status:
	
	
	
	return SUCCESS
	
## think about helper functions down here

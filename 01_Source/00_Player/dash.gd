extends Area2D

@onready var parent = get_parent()
var dash_speed_mult: float = 1.0

func start_dash(speed: float, distance: float, direction: Vector2) -> void:
	speed = speed*dash_speed_mult
	parent.velocity = speed*direction
	var time = distance/speed
	parent.is_dashing = true
	parent.using_attack_or_special_or_dash = true
	parent.is_invincible = true
	await get_tree().create_timer(time).timeout
	end_dash()
	return

func end_dash() -> void:
	parent.velocity = Vector2.ZERO
	parent.is_dashing = false
	parent.using_attack_or_special_or_dash = false
	parent.get_node("DashTrailHelper").get_node("DashTrail").visible = false
	parent.dashed_into_enemies.clear()
	if !is_inside_tree():
		parent.is_invincible = false
		return
	await get_tree().create_timer(0.2).timeout
	parent.is_invincible = false
	return

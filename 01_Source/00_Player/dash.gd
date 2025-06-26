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
	parent.is_invincible = false
	parent.velocity = Vector2.ZERO
	parent.is_dashing = false
	parent.using_attack_or_special_or_dash = false
	parent.dashed_into_enemies.clear()
	return

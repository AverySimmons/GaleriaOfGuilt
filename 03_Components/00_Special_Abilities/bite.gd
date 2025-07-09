extends SpecialAbility

@onready var collision_shape_2d = $CollisionShape2D

func _ready() -> void:
	super._ready()
	damage = 40
	cooldown = 8
	chargeup = 0.5
	active_time = 0.6
	special_slowdown = 0.4
	flinch_amount = 1.2
	blood_gain_multiplier = 1.5
	chargeup_slowdown = 0.3
	
	connect("area_entered", Callable(self, "_on_area_entered"))
	parent.start_dash.connect(dash_cancel)
	pass

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if !is_active:
		return
	for area in enemies_just_entered:
		if not area: continue
		var enemy = area.owner
		if (enemy is not Enemy and enemy is not Boss) || hit_enemies.has(enemy):
			continue
		parent.gain_blood("special", blood_gain_multiplier, enemy)
		hit_enemies[enemy] = null
		enemy.take_damage(damage, flinch_amount, 0)
		parent.dealt_damage_took_damage = true
		
	enemies_just_entered.clear()
	
	active_timer = move_toward(active_timer, 0, delta)
	if active_timer <= 0:
		parent.using_attack_or_special_or_dash = false
		monitoring = false
		is_active = false	
		hit_enemies.clear()
		special_slowdown_actual = 1.0
		collision_shape_2d.get_node("Sprite2D").visible = false
	pass


func use_ability() -> void:
	
	super.use_ability()
	# Chargeup
	special_slowdown_actual = chargeup_slowdown
	await get_tree().create_timer(chargeup).timeout
	is_active = true
	active_timer = active_time * parent.bb_hitspd_inc
	parent.using_attack_or_special_or_dash = true
	if !is_active:
		return
	active_timer = active_time * parent.bb_hitspd_inc
	special_slowdown_actual = special_slowdown
	
	var mouse_pos: Vector2 = get_global_mouse_position()
	var direction: Vector2 = (mouse_pos - global_position).normalized()
	var angle: float = direction.angle()
	monitoring = true
	if !is_inside_tree(): return
	await get_tree().physics_frame
	var facing_dir = parent.name_from_vect_dir(direction)
	facing_dir = parent.update_facing_direction(facing_dir)
	parent.animation_player.play("bite_" + facing_dir)
	AudioData.play_sound("bite", parent.bite_sound)
	var offset = direction * Vector2(150, 150)
	offset += Vector2(0, -20)
	collision_shape_2d.global_position = parent.global_position + offset
	print(collision_shape_2d.global_position)
	print(parent.global_position)
	if has_overlapping_areas():
		parent.dealt_damage_took_damage = true
	collision_shape_2d.get_node("Sprite2D").visible = true
	$AnimationPlayer.play("bite")
	var enemies_hit = get_overlapping_areas()
	for area in enemies_hit:
		var enemy = area.owner
		if enemy is not Enemy or enemy is not Boss:
			continue
		parent.gain_blood("special", blood_gain_multiplier, enemy)
		hit_enemies[enemy] = null
		enemy.take_damage(damage * GameData.player.special_damage_increase, flinch_amount, 0)
	return

func _on_area_entered(area: Area2D) -> void:
	enemies_just_entered.append(area)
	pass

func dash_cancel() -> void:
	if is_active:
		$AnimationPlayer.stop()
		active_timer = 0
		parent.using_attack_or_special_or_dash = false
		monitoring = false
		is_active = false
		hit_enemies.clear()
		special_slowdown_actual = 1.0
		collision_shape_2d.get_node("Sprite2D").visible = false

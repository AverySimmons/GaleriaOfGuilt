extends SpecialAbility

func _ready() -> void:
	super._ready()
	damage = 50
	cooldown = 4
	chargeup = 0.4
	active_time = 0.6
	special_slowdown = 0.4
	flinch_amount = 0.3
	blood_gain_multiplier = 2.5
	chargeup_slowdown = 0.2
	
	connect("area_entered", Callable(self, "_on_area_entered"))
	pass

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if !is_active:
		return
	for enemy in enemies_just_entered:
		if enemy is not Enemy || hit_enemies.has(enemy):
			continue
		parent.blood_bar += parent.bb_hit * blood_gain_multiplier
		hit_enemies[enemy] = null
		enemy.take_damage(damage, flinch_amount)
	enemies_just_entered.clear()
	
	active_timer = move_toward(active_timer, 0, delta)
	if active_timer <= 0:
		parent.using_attack_or_special = false
		monitoring = false
		is_active = false	
		hit_enemies.clear()
		special_slowdown_actual = 1.0
	pass


func use_ability() -> void:
	var mouse_pos: Vector2 = get_global_mouse_position()
	var direction: Vector2 = mouse_pos - global_position
	var angle: float = direction.angle()
	rotation = angle
	
	super.use_ability()
	if has_overlapping_areas():
		parent.dealt_damage_took_damage = true
	
	var enemies_hit = get_overlapping_areas()
	for enemy in enemies_hit:
		if enemy is not Enemy:
			continue
		parent.blood_bar += parent.bb_hit * blood_gain_multiplier
		hit_enemies[enemy] = null
		enemy.take_damage(damage, flinch_amount)
	return

func _on_area_entered(area: Area2D) -> void:
	enemies_just_entered.append(area)
	pass

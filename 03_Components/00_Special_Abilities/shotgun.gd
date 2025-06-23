extends SpecialAbility

func _ready() -> void:
	super._ready()
	damage = 15
	cooldown = 5
	chargeup = 0.4
	active_time = 0.2
	special_slowdown = 0.4
	flinch_amount = 0.1
	chargeup_slowdown = 0.4
	pass

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	if active_timer <= 0:
		parent.using_attack_or_special = false
		is_active = false	
		special_slowdown_actual = 1.0
	pass

func use_ability() -> void:
	var mouse_pos: Vector2 = get_global_mouse_position()
	var direction: Vector2 = mouse_pos - global_position
	var angle: float = direction.angle()
	rotation = angle
	
	
	
	return

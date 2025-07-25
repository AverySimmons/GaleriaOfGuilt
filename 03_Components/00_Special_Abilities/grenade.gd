extends SpecialAbility

var knockback_amount: float = 50
var speed: float = 500
var grenade_scene = preload("res://01_Source/04_Projectiles/grenade_projectile.tscn")

func _ready() -> void:
	super._ready()
	damage = 20
	cooldown = 8
	chargeup = 0.3
	active_time = 0.1
	special_slowdown = 0.5
	flinch_amount = 0.6
	chargeup_slowdown = 0.4
	parent.start_dash.connect(dash_cancel)
	pass

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if !is_active:
		return
	if active_timer <= 0:
		parent.using_attack_or_special_or_dash = false
		is_active = false
		special_slowdown_actual = 1.0
	active_timer = move_toward(active_timer, 0, delta)
	pass

func use_ability(stupid: float) -> void:
	stupid_mult = stupid
	var mouse_pos: Vector2 = get_global_mouse_position()
	var direction: Vector2 = (mouse_pos - global_position).normalized()
	var angle: float = direction.angle()
	rotation = angle
	super.use_ability(stupid_mult)
	if !is_inside_tree(): return
	var projectiles_scene = get_tree().current_scene.get_node_or_null("Projectiles")
	if !projectiles_scene:
		projectiles_scene = get_tree().current_scene
	
	var grenade = grenade_scene.instantiate()
	grenade.global_position = global_position
	projectiles_scene.add_child(grenade)
	grenade.get_thrown(mouse_pos, speed, damage*stupid_mult, flinch_amount, knockback_amount)
	return

func dash_cancel() -> void:
	if is_active:
		parent.using_attack_or_special_or_dash = false
		is_active = false
		special_slowdown_actual = 1.0
	return

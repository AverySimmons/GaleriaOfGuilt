extends SpecialAbility

var knockback_amount: float = 50
var speed: float = 500
var grenade_scene = preload("res://01_Source/04_Projectiles/grenade_projectile.tscn")

func _ready() -> void:
	super._ready()
	damage = 60
	cooldown = 5
	chargeup = 0.3
	active_time = 0.1
	special_slowdown = 0.5
	flinch_amount = 0.5
	chargeup_slowdown = 0.4
	pass

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	if active_timer <= 0:
		parent.using_attack_or_special = false
		is_active = false
		special_slowdown_actual = 1.0
	active_timer = move_toward(active_timer, 0, delta)
	
	pass

func use_ability() -> void:
	var mouse_pos: Vector2 = get_global_mouse_position()
	var direction: Vector2 = (mouse_pos - global_position).normalized()
	var angle: float = direction.angle()
	rotation = angle
	
	super.use_ability()
	
	var projectiles_scene = get_tree().current_scene.get_node_or_null("Projectiles")
	if !projectiles_scene:
		projectiles_scene = get_tree().current_scene
	
	var grenade = grenade_scene.instantiate()
	grenade.global_position = global_position
	projectiles_scene.add_child(grenade)
	grenade.get_thrown(mouse_pos, speed)
	return

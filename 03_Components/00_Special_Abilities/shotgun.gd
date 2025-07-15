extends SpecialAbility

var bullet_scene = preload("res://01_Source/04_Projectiles/shotgun_blast.tscn")
var bullet_speed = 1000
var cur_bullet_speed

func _ready() -> void:
	super._ready()
	damage = 8
	cooldown = 4.5
	chargeup = 0.2
	active_time = 0.2
	special_slowdown = 0.3
	flinch_amount = 0.0
	chargeup_slowdown = 0.15
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
	var mouse_pos: Vector2 = get_global_mouse_position()
	var direction: Vector2 = mouse_pos - global_position
	var angle: float = direction.angle()
	rotation = angle
	stupid_mult = stupid
	super.use_ability(stupid_mult)
	# For shooting out bullets semi-randomly
	var angle_variance: float = -80/180.0
	var angle_randomness: float = 5.0/180.0
	
	var muzzle_position: Vector2 = $CollisionShape2D.global_transform * Vector2($CollisionShape2D.shape.extents.x, 0)
	var offset: float = -3
	if !is_inside_tree(): return
	var projectiles_scene = get_tree().current_scene.get_node_or_null("Projectiles")
	if !projectiles_scene:
		projectiles_scene = get_tree().current_scene
	
	for i in range(16):
		var new_bullet = bullet_scene.instantiate()
		
		cur_bullet_speed = randfn(bullet_speed, 100)
		new_bullet.global_position = muzzle_position + (Vector2(0, offset).rotated(angle))
		new_bullet.rotation = angle
		var angle_shot_out: float = angle + angle_variance
		new_bullet.get_shot(angle_shot_out-angle_randomness, angle_shot_out+angle_randomness, cur_bullet_speed, damage*stupid_mult, flinch_amount)
		angle_variance += 10/180.0
		
		offset += 1
		
		projectiles_scene.add_child(new_bullet)
	
	return

func dash_cancel() -> void:
	if is_active:
		parent.using_attack_or_special_or_dash = false
		is_active = false
		special_slowdown_actual = 1.0
	return

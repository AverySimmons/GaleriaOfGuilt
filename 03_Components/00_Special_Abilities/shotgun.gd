extends SpecialAbility

var bullet_scene = preload("res://01_Source/04_Projectiles/shotgun_blast.tscn")
var bullet_speed = 600
var cur_bullet_speed

func _ready() -> void:
	super._ready()
	damage = 15
	cooldown = 5
	chargeup = 0.4
	active_time = 0.2
	special_slowdown = 0.5
	flinch_amount = 0.1
	chargeup_slowdown = 0.3
	pass

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	if active_timer <= 0:
		parent.using_attack_or_special_or_dash = false
		is_active = false
		special_slowdown_actual = 1.0
	active_timer = move_toward(active_timer, 0, delta)
	
	pass

func use_ability() -> void:
	var mouse_pos: Vector2 = get_global_mouse_position()
	var direction: Vector2 = mouse_pos - global_position
	var angle: float = direction.angle()
	rotation = angle
	
	super.use_ability()
	# For shooting out bullets semi-randomly
	var angle_variance: float = -30.0/180.0
	var angle_randomness: float = 5.0/180.0
	cur_bullet_speed = bullet_speed
	
	var muzzle_position: Vector2 = $CollisionShape2D.global_transform * Vector2($CollisionShape2D.shape.extents.x, 0)
	var offset: float = -3
	
	var projectiles_scene = get_tree().current_scene.get_node_or_null("Projectiles")
	if !projectiles_scene:
		projectiles_scene = get_tree().current_scene
	
	for i in range(6):
		var new_bullet = bullet_scene.instantiate()
		projectiles_scene.add_child(new_bullet)
		
		new_bullet.global_position = muzzle_position + (Vector2(0, offset).rotated(angle))
		new_bullet.rotation = angle
		var angle_shot_out: float = angle + angle_variance
		new_bullet.get_shot(angle_shot_out-angle_randomness, angle_shot_out+angle_randomness, cur_bullet_speed, damage, flinch_amount)
		angle_variance += 10.0/180.0
		
		offset += 1
	
	return

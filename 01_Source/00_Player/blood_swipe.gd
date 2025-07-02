extends Area2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

@onready var parent: Player = get_parent()
var is_active: bool = false
var active_time: float = 0.5
var active_timer: float
var hit_enemies: Dictionary = {}
var enemies_just_entered: Array
var damage_unmodified: float = 20
var damage: float = damage_unmodified
var damage_mult = 1.0
var haha_yooo: float = 0.4
var attack_slowdown: float = 0.4
var attack_slowdown_actual: float = 1.0
var flinch_amount: float = 0.2

# For upgrades
var retractable_counter: int = 0

func _ready() -> void:
	connect("area_entered", Callable(self, "_on_area_entered"))
	monitoring = false
	parent.burst_begin.connect(on_burst_begin)
	parent.burst_end.connect(on_burst_end)
	parent.start_dash.connect(dash_cancel)
	pass

func _physics_process(delta: float) -> void:
	if !is_active:
		return
	for enemy in enemies_just_entered:
		if enemy is not Enemy || hit_enemies.has(enemy):
			continue
		parent.gain_blood("swipe", 1.0, enemy)
		hit_enemies[enemy] = null
		enemy.take_damage(damage, flinch_amount, 0)
		#print(damage)
		if UpgradeData.upgrades_gained[UpgradeData.LIFESTEAL]:
			parent.heal_damage(2)
		# Enemy take damage thing
	enemies_just_entered.clear()
	
	active_timer = move_toward(active_timer, 0, delta)
	if active_timer <= 0:
		parent.using_attack_or_special_or_dash = false
		monitoring = false
		is_active = false
		hit_enemies.clear()
		attack_slowdown_actual = 1.0
		damage = damage_unmodified
		if UpgradeData.upgrades_gained[UpgradeData.RETRACT_SWIPE]:
			if parent.burst_timer == 0:
				collision_shape_2d.get_node("Slash").modulate = Color(1, 1, 1, 1)
			else:
				collision_shape_2d.get_node("Slash").modulate = Color(1.0, 0.8, 0.9)
	pass

func initiate_attack(upgrade_mult: float) -> void:
	# Animations:
	# Enemies flash red - In enemy take damage thing
	# Animation player stuff
	# Audio
	damage *= upgrade_mult * damage_mult
	var mouse_pos: Vector2 = get_global_mouse_position()
	var direction: Vector2 = parent.global_position.direction_to(mouse_pos)
	var angle: float = direction.angle()
	
	## remove my comments !! if u want
	
	## this vector2 controls the distance of the slash from the player
	var offset = direction * Vector2(135, 135)
	collision_shape_2d.global_position = parent.global_position + offset
	
	## this is some wonkey code to make sure the slash always goes
	## top to bottom on both sides
	var abs_dir_ang = Vector2(abs(direction.x), direction.y).angle()
	collision_shape_2d.rotation = abs_dir_ang
	if direction.x < 0:
		collision_shape_2d.scale.x = 1
		collision_shape_2d.rotation *= -1
	else:
		collision_shape_2d.scale.x = -1
	
	if UpgradeData.upgrades_gained[UpgradeData.RETRACT_SWIPE]:
		retractable_counter += 1
		#print(retractable_counter)
		if retractable_counter >= 3:
			retractable_counter = 0
			damage = damage * 2
			collision_shape_2d.get_node("Slash").modulate = Color(1, 0, 0)
	animation_player.play("blood_swipe")
	
	# Make player face direction of swing
	## for now I've moved the player animation code to the
	## player script since it had more easy access to the
	## animation player / helper functions
	
	active_timer = active_time * parent.bb_hitspd_inc
	#print(active_timer)
	attack_slowdown_actual = attack_slowdown
	is_active = true
	monitoring = true
	
	## I've added this to detect something after setting monitoring to true
	## it needs a physics frame to update
	await get_tree().physics_frame
	
	parent.using_attack_or_special_or_dash = true
	
	if has_overlapping_areas():
		parent.dealt_damage_took_damage = true
	
	var enemies_hit = get_overlapping_areas()
	for area in enemies_hit:
		## I've switched this to the area's owner, since enemy's hurtbox
		## is just an area - owner gives us the root node of the scene
		var enemy = area.owner
		if enemy is not Enemy:
			continue
		var enemy_dir = parent.global_position.direction_to(enemy.global_position)
		$BloodModule.enemy_hit(enemy.global_position, enemy_dir)
		parent.gain_blood("swipe", 1.0, enemy)
		hit_enemies[enemy] = null
		enemy.take_damage(damage, flinch_amount, 0)
		if UpgradeData.upgrades_gained[UpgradeData.LIFESTEAL]:
			parent.heal_damage(2)
	# Functions:
	# Deal dmg
	# Gain blood for each enemy hit and killed
	return

func _on_area_entered(area: Area2D) -> void:
	#enemies_just_entered.append(area)
	pass

func on_burst_begin() -> void:
	attack_slowdown = 1.0
	collision_shape_2d.get_node("Slash").modulate = Color(1.0, 0.8, 0.9)
	if UpgradeData.upgrades_gained[UpgradeData.BR_INCREASE]:
		damage_mult = 1.5
	return

func on_burst_end() -> void:
	attack_slowdown = haha_yooo
	collision_shape_2d.get_node("Slash").modulate = Color(1, 1, 1)
	if UpgradeData.upgrades_gained[UpgradeData.BR_INCREASE]:
		damage_mult = 1.0
	return

func dash_cancel() -> void:
	if is_active:
		animation_player.stop()
		animation_player.play("RESET")
		active_timer = 0
		parent.using_attack_or_special_or_dash = false
		monitoring = false
		is_active = false
		hit_enemies.clear()
		attack_slowdown_actual = 1.0
		damage = damage_unmodified
		if UpgradeData.upgrades_gained[UpgradeData.RETRACT_SWIPE]:
			if parent.burst_timer == 0:
				collision_shape_2d.get_node("Slash").modulate = Color(1, 1, 1, 1)
			else:
				collision_shape_2d.get_node("Slash").modulate = Color(1.0, 0.8, 0.9)
	return

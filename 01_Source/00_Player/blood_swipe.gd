extends Area2D

@onready var parent: CharacterBody2D = get_parent()
var is_active: bool = false
var active_time: float = 0.5
var active_timer: float
var hit_enemies: Dictionary = {}
var enemies_just_entered: Array
var damage: float = 20
var attack_slowdown: float = 0.4
var attack_slowdown_actual: float = 1.0
var flinch_amount: float = 0.2

func _ready() -> void:
	connect("area_entered", Callable(self, "_on_area_entered"))
	monitoring = false
	pass

func _physics_process(delta: float) -> void:
	if !is_active:
		return
	for enemy in enemies_just_entered:
		if enemy is not Enemy || hit_enemies.has(enemy):
			continue
		parent.blood_bar += parent.bb_hit
		hit_enemies[enemy] = null
		enemy.take_damage(damage, flinch_amount)
		# Enemy take damage thing
	enemies_just_entered.clear()
	
	active_timer = move_toward(active_timer, 0, delta)
	if active_timer <= 0:
		parent.using_attack_or_special = false
		monitoring = false
		is_active = false
		hit_enemies.clear()
		attack_slowdown_actual = 1.0
	pass

func initiate_attack() -> void:
	# Animations:
	# Enemies flash red - In enemy take damage thing
	# Animation player stuff
	# Audio
	var mouse_pos: Vector2 = get_global_mouse_position()
	var direction: Vector2 = mouse_pos - global_position
	var angle: float = direction.angle()
	rotation = angle
	# Make player face direction of swing
	
	active_timer = active_time * parent.bb_hitspd_inc
	attack_slowdown_actual = attack_slowdown
	is_active = true
	monitoring = true
	parent.using_attack_or_special = true
	
	if has_overlapping_areas():
		parent.dealt_damage_took_damage = true
	
	var enemies_hit = get_overlapping_areas()
	for enemy in enemies_hit:
		if enemy is not Enemy:
			continue
		parent.blood_bar += parent.bb_hit
		hit_enemies[enemy] = null
		enemy.take_damage(damage, flinch_amount)
	# Functions:
	# Deal dmg
	# Gain blood for each enemy hit and killed
	return

func _on_area_entered(area: Area2D) -> void:
	enemies_just_entered.append(area)
	pass

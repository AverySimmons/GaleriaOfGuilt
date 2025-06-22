extends Area2D

@onready var parent: CharacterBody2D = get_parent()
var is_active: bool = false
var active_time: float = 0.6
var active_timer: float
var hit_enemies: Dictionary = {}
var enemies_just_entered: Array
var damage: float = 20
var attack_slowdown: float = 0.3
var attack_slowdown_actual: float = 1.0

func _ready() -> void:
	connect("area_entered", Callable(self, "_on_area_entered"))
	pass

func _physics_process(delta: float) -> void:
	if !is_active:
		return
	for enemy in enemies_just_entered:
		if enemy is not Enemy || hit_enemies.has(enemy):
			continue
		parent.blood_bar += parent.bb_hit
		hit_enemies[enemy] = null
		# Enemy take damage thing
	enemies_just_entered.clear()
	
	active_timer = move_toward(active_timer, 0, delta)
	if active_timer <= 0:
		is_active = false
		hit_enemies.clear()
		attack_slowdown_actual = 1.0
	pass

func initiate_attack() -> void:
	# Animations:
	# Slight screen shake?
	# Enemies flash red - In enemy take damage thing
	# Animation player stuff
	# Audio
	active_timer = active_time
	attack_slowdown_actual = attack_slowdown
	is_active = true
	
	if has_overlapping_areas():
		parent.dealt_damage_took_damage = true
	
	var enemies_hit = get_overlapping_areas()
	for enemy in enemies_hit:
		if enemy is not Enemy:
			continue
		parent.blood_bar += parent.bb_hit
		hit_enemies[enemy] = null
	# Functions:
	# Deal dmg
	# Gain blood for each enemy hit and killed
	return

func _on_area_entered(area: Area2D) -> void:
	enemies_just_entered.append(area)
	pass

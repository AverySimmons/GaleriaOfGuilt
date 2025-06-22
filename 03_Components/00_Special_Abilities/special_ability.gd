class_name SpecialAbility
extends Area2D

@onready var parent = get_parent()
var damage: float
var cooldown: float
var chargeup: float
var chargeup_slowdown: float
var is_active: bool = false
var active_time: float
var active_timer: float
var hit_enemies: Dictionary = {}
var enemies_just_entered: Array
var special_slowdown: float
var special_slowdown_actual: float = 1.0
var flinch_amount: float
var blood_gain_multiplier: float = 1.0

func use_ability() -> void:
	# Chargeup
	special_slowdown_actual = chargeup_slowdown
	await get_tree().create_timer(chargeup).timeout
	print("Yo")
	
	monitoring = true
	parent.using_attack_or_special = true
	active_timer = active_time * parent.bb_hitspd_inc
	special_slowdown_actual = special_slowdown
	is_active = true
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

func _ready() -> void:
	monitoring = false
	pass

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
	# Make player face direction of swing
	
	monitoring = true
	parent.using_attack_or_special = true
	active_timer = active_time * parent.bb_hitspd_inc
	special_slowdown_actual = special_slowdown
	is_active = true
	
	return

func _ready() -> void:
	monitoring = false
	pass

func _physics_process(delta: float) -> void:
	pass

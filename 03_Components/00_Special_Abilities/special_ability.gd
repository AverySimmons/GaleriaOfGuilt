class_name SpecialAbility
extends Area2D

@onready var parent = get_parent()
var damage: float
var cooldown: float
var chargeup: float

func use_ability() -> void:
	monitoring = true
	parent.using_attack_or_special = true
	return

func _ready() -> void:
	monitoring = false
	pass

extends Area2D

@onready var parent: CharacterBody2D = get_parent()
func initiate_attack() -> void:
	# Animations:
	# Slight screen shake?
	# Enemies flash red
	# Animation player stuff
	# Audio
	if has_overlapping_areas():
		parent.dealt_damage_took_damage = true
	
	var enemies_hit = get_overlapping_areas()
	for enemy in enemies_hit:
		if enemy is not Enemy:
			continue
		parent.blood_bar += parent.bb_hit
	# Functions:
	# Deal dmg
	# Gain blood for each enemy hit and killed
	return

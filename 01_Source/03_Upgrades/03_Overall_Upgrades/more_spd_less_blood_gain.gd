extends Upgrade

func _init() -> void:
	upgrade_name = "Destructive Haste" 
	upgrade_description = "You have an increased baseline movement speed, but blood gain from everything is slightly reduced."
	icon = preload("res://00_Assets/00_Sprites/upgrade_icons/boots_super.png")
	upgrade_number = UpgradeData.MORE_SPD_LESS_BG
	upgrade_scene = self
	type = 0
	pass

func choose_upgrade() -> void:
	super.choose_upgrade()
	GameData.player.bb_multiplier2 *= 0.85
	GameData.player.baseline_speed += 140
	return

extends Upgrade

func _init() -> void:
	upgrade_name = "Insatiable Appetite" 
	upgrade_description = "Your blood bar has a doubled capacity, but you gain less blood from everything."
	icon = preload("res://00_Assets/00_Sprites/upgrade_icons/blood_minus.png")
	upgrade_number = UpgradeData.BB_SIZE_INC_LESS_BG
	upgrade_scene = self
	type = 0
	pass

func choose_upgrade() -> void:
	super.choose_upgrade()
	GameData.player.bb_max *= 2
	GameData.player.bb_multiplier2 *= 0.6667
	return

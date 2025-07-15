extends Upgrade

func _init() -> void:
	upgrade_name = "Drinking Drool"
	upgrade_description = "Slashing enemies decreases your special cooldown."
	icon = preload("res://00_Assets/00_Sprites/upgrade_icons/slash_plus.png")
	upgrade_number = UpgradeData.SLASH_SPCD
	upgrade_scene = self
	type = 2
	pass

func choose_upgrade() -> void:
	
	super.choose_upgrade()
	return

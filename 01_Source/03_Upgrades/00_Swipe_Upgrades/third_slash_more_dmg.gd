extends Upgrade

func _init() -> void:
	upgrade_name = "Retractable Claws"
	upgrade_description = "Your third swipe deals double damage."
	icon = preload("res://00_Assets/00_Sprites/upgrade_icons/slash_three.png")
	upgrade_number = UpgradeData.RETRACT_SWIPE
	upgrade_scene = self
	type = 2
	pass

func choose_upgrade() -> void:
	super.choose_upgrade()
	return

extends Upgrade

func _init() -> void:
	upgrade_name = "Retractable Claws"
	upgrade_description = "Your third swipe deals more damage"
	icon = preload("res://00_Assets/00_Sprites/upgrade_icons/slash_three.png")
	upgrade_number = UpgradeData.RETRACT_SWIPE
	print(upgrade_number)
	upgrade_scene = self
	pass

func choose_upgrade() -> void:
	super.choose_upgrade()
	return

extends Upgrade

func _ready() -> void:
	upgrade_name = "Retractable Claws"
	upgrade_description = "Your third swipe deals more damage"
	icon = preload("res://00_Assets/00_Sprites/upgrade_icons/slash.png")
	upgrade_number = UpgradeData.CHARGE_SWIPE
	upgrade_scene = UpgradeData.CHARGE_SWIPE_SCENE
	pass

func choose_upgrade() -> void:
	super.choose_upgrade()
	return

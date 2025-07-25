extends Upgrade

func _init() -> void:
	upgrade_name = "Artful Mauling"
	upgrade_description = "Your swipe attack generates less blood but deals 50% more damage."
	icon = preload("res://00_Assets/00_Sprites/upgrade_icons/slash_glowing.png")
	upgrade_number = UpgradeData.COSTS_BLOOD_MORE_DMG
	upgrade_scene = self
	type = 2
	pass

func choose_upgrade() -> void:
	super.choose_upgrade()
	GameData.player.swipe_blood_cost += 2
	GameData.player.upgrade_swipe_mult *= 1.5
	return

extends Upgrade

func _init() -> void:
	upgrade_name = "Torture Them"
	upgrade_description = "Your swipe attack generates 30% more blood."
	icon = preload("res://00_Assets/00_Sprites/upgrade_icons/slash_blood.png")
	upgrade_number = UpgradeData.SWIPE_MORE_BG
	upgrade_scene = self
	type = 2
	pass

func choose_upgrade() -> void:
	super.choose_upgrade()
	GameData.player.swipe_bb_gain *= 1.3
	return

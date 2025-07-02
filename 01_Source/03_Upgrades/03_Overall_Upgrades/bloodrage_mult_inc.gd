extends Upgrade

func _init() -> void:
	upgrade_name = "" 
	upgrade_description = "You attack faster, move faster, and have stronger swipes while in a bloodrage."
	icon = preload("res://00_Assets/00_Sprites/upgrade_icons/slash_evil.png")
	upgrade_number = UpgradeData.BR_INCREASE
	upgrade_scene = self
	type = 0
	pass

func choose_upgrade() -> void:
	super.choose_upgrade()
	GameData.player.burst_mult *= 1.3
	return

extends Upgrade

func _init() -> void:
	upgrade_name = "Monstrous Tenacity"
	upgrade_description = "Your dash now has two charges, but with much lower distance."
	icon = preload("res://00_Assets/00_Sprites/upgrade_icons/dash_plus.png")
	upgrade_number = UpgradeData.DASH_CHARGES
	upgrade_scene = self
	type = 1
	pass

func choose_upgrade() -> void:
	super.choose_upgrade()
	GameData.player.dash_distance *= 0.75
	GameData.player.dash_charges += 1
	GameData.player.dash_charges_amt += 1
	return

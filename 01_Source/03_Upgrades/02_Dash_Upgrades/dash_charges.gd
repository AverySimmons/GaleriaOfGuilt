extends Upgrade

func _init() -> void:
	upgrade_name = "Monstrous Tenacity"
	upgrade_description = "When your dash cooldown resets, you now get two uses of your dash, but with much lower distance."
	icon = preload("res://00_Assets/00_Sprites/upgrade_icons/boots_super.png")
	upgrade_number = UpgradeData.DASH_DAMAGE
	upgrade_scene = self
	pass

func choose_upgrade() -> void:
	super.choose_upgrade()
	GameData.player.dash_distance *= 0.6
	GameData.player.dash_charges += 1
	GameData.player.dash_charges_amt += 1
	return

extends Upgrade

func _init() -> void:
	upgrade_name = "Rapid Jaws"
	upgrade_description = "Your special has a reduced cooldown, but all bloodgain is slightly reduced."
	icon = preload("res://00_Assets/00_Sprites/upgrade_icons/bite_plus.png")
	upgrade_number = UpgradeData.SPCD_DOWN_BLOOD_DOWN
	upgrade_scene = self
	type = 3
	pass

func choose_upgrade() -> void:
	super.choose_upgrade()
	GameData.player.spcd_increase *= 0.7
	GameData.player.bb_multiplier2 *= 0.85
	return

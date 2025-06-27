extends Upgrade

func _init() -> void:
	upgrade_name = "Bloodbath"
	upgrade_description = "Using your special costs hp, but kills reduce special cooldown."
	icon = preload("res://00_Assets/00_Sprites/upgrade_icons/bite_glowing.png")
	upgrade_number = UpgradeData.SPECIAL_CD_RED_COST_HP
	upgrade_scene = self
	pass

func choose_upgrade() -> void:
	super.choose_upgrade()
	var player = GameData.player
	player.get_signal_upgrade("kill_lower_special_cd")
	return

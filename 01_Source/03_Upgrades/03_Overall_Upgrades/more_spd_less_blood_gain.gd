extends Upgrade

func _init() -> void:
	upgrade_name = "MORE MORE MORE" 
	upgrade_description = "You have an increased baseline movement speed."
	icon = preload("res://00_Assets/00_Sprites/upgrade_icons/boots_super.png")
	upgrade_number = UpgradeData.MORE_SPD_LESS_BG
	upgrade_scene = self
	type = 0
	pass

func choose_upgrade() -> void:
	super.choose_upgrade()
	GameData.player.baseline_speed += 70
	return

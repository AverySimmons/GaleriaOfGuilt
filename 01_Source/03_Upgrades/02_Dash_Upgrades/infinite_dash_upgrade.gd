extends Upgrade

func _init() -> void:
	upgrade_name = "Your Mind Screams"
	upgrade_description = "Lower your dash cooldown and increase it's distance, your dash now costs blood."
	icon = preload("res://00_Assets/00_Sprites/upgrade_icons/dash_super.png")
	upgrade_number = UpgradeData.DASH_INFINITE
	upgrade_scene = self
	type = 1
	pass

func choose_upgrade() -> void:
	super.choose_upgrade()
	GameData.player.dash_speed *= 2.0
	GameData.player.dash_cd = 0.25
	GameData.player.dash_blood_cost = 7
	return

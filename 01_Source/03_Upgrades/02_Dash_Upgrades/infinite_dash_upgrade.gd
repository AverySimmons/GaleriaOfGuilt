extends Upgrade

func _init() -> void:
	upgrade_name = "Your Mind Screams"
	upgrade_description = "While you have blood, lower your dash cooldown and increase it's speed, but your dash costs blood."
	icon = preload("res://00_Assets/00_Sprites/upgrade_icons/dash_super.png")
	upgrade_number = UpgradeData.DASH_INFINITE
	upgrade_scene = self
	type = 1
	pass

func choose_upgrade() -> void:
	super.choose_upgrade()
	GameData.player.dash_speed *= 2.0
	GameData.player.dash_blood_cost = 7
	return

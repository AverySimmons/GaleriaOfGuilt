extends Upgrade

func _init() -> void:
	upgrade_name = "Reckless Restlessness"
	upgrade_description = "Dashing has almost no cooldown but costs blood. Yippee!"
	icon = preload("res://00_Assets/00_Sprites/upgrade_icons/dash_super.png")
	upgrade_number = UpgradeData.DASH_INFINITE
	upgrade_scene = self
	pass

func choose_upgrade() -> void:
	super.choose_upgrade()
	GameData.player.dash_blood_cost += 7
	GameData.player.dash_cd = 0.5
	return

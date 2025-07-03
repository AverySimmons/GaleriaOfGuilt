extends Upgrade

func _init() -> void:
	upgrade_name = "Unceasing Hunt"
	upgrade_description = "Your dash has increased distance, and generates blood when dashing through enemies."
	icon = preload("res://00_Assets/00_Sprites/upgrade_icons/dash_slashing.png")
	upgrade_number = UpgradeData.DASH_DISTANCE_BLOOD_GAIN
	upgrade_scene = self
	type = 1
	pass

func choose_upgrade() -> void:
	super.choose_upgrade()
	GameData.player.dash_distance += 100
	GameData.player.dash_speed *= 1.1
	return

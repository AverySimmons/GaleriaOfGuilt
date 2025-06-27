extends Upgrade

func _init() -> void:
	upgrade_name = "Ain't no such thing as a free lunch (my grandma said this) (she didn't actually, she loves giving homeless people free lunches)"
	upgrade_description = "Your dash has an increased distance, and provides a little bit of blood when you dash over an enemy."
	icon = preload("res://00_Assets/00_Sprites/upgrade_icons/dash_slashing.png")
	upgrade_number = UpgradeData.DASH_DISTANCE_BLOOD_GAIN
	upgrade_scene = self
	pass

func choose_upgrade() -> void:
	super.choose_upgrade()
	GameData.player.dash_distance += 100
	return

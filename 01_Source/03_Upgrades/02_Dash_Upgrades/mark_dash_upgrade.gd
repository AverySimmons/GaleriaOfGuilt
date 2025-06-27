extends Upgrade

func _init() -> void:
	upgrade_name = "Easy Prey" # (The Meat King's Party!) That's what they call Jai (Jai said this) (mmm... hemomancer)
	upgrade_description = "Hitting an enemy with your dash marks them. Marked enemies provide more blood when hit."
	icon = preload("res://00_Assets/00_Sprites/upgrade_icons/dash_slashing.png")
	upgrade_number = UpgradeData.MARK_DASH
	upgrade_scene = self
	pass

func choose_upgrade() -> void:
	super.choose_upgrade()
	return

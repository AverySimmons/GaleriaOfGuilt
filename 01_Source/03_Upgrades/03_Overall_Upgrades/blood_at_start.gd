extends Upgrade

func _init() -> void:
	upgrade_name = "Smell of Prey" 
	upgrade_description = "Gain some blood when you enter an unexplored room."
	icon = preload("res://00_Assets/00_Sprites/upgrade_icons/blood.png")
	upgrade_number = UpgradeData.ENTER_ROOM
	upgrade_scene = self
	type = 0
	pass

func choose_upgrade() -> void:
	super.choose_upgrade()
	return

extends Upgrade

func _init() -> void:
	upgrade_name = "Blood Vials" 
	upgrade_description = "Gain some blood when you enter a room"
	icon = preload("res://00_Assets/00_Sprites/upgrade_icons/blood.png")
	upgrade_number = UpgradeData.BB_SIZE_INC_LESS_BG
	upgrade_scene = self
	type = 0
	pass

func choose_upgrade() -> void:
	super.choose_upgrade()
	return

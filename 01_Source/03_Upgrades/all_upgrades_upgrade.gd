extends Upgrade

func _init() -> void:
	upgrade_name = "How'd you get here?" 
	upgrade_description = "Pick this if you wanna keep your special ig. Isn't this a cool icon? Hope you had fun!"
	icon = preload("res://00_Assets/00_Sprites/upgrade_icons/blood_sword2_super.png")
	upgrade_number = UpgradeData.ALL_UPGRADES
	upgrade_scene = self
	type = 3
	pass

func choose_upgrade() -> void:
	super.choose_upgrade()
	return

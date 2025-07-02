extends Upgrade

func _init() -> void:
	upgrade_name = "Hemo-Protectors!!!!!" 
	upgrade_description = "You take damage to the blood bar first before your hp bar."
	icon = preload("res://00_Assets/00_Sprites/upgrade_icons/bloody_tendrils.png")
	upgrade_number = UpgradeData.BLOOD_AS_HP
	upgrade_scene = self
	type = 0
	pass

func choose_upgrade() -> void:
	super.choose_upgrade()
	return

extends Upgrade

func _init() -> void:
	upgrade_name = "Sentient Wounds" 
	upgrade_description = "Losing blood no longer heals you, but at high blood levels you have constant health regen."
	icon = preload("res://00_Assets/00_Sprites/upgrade_icons/bloody_tendrils.png")
	upgrade_number = UpgradeData.HIGH_BLOOD_REGEN
	upgrade_scene = self
	type = 0
	pass

func choose_upgrade() -> void:
	super.choose_upgrade()
	return

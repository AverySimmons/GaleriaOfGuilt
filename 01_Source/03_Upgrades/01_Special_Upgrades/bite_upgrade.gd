extends Upgrade

func _ready() -> void:
	upgrade_name = "Bite"
	upgrade_description = "Replace your special with a bite that provides more blood."
	icon = preload("res://00_Assets/00_Sprites/upgrade_icons/blood_sword1_super.png")
	upgrade_number = UpgradeData.BITE
	pass

func choose_upgrade() -> void:
	super.choose_upgrade()
	
	return

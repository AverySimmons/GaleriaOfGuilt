extends Upgrade

func _init() -> void:
	upgrade_name = "Blood Fasting" 
	upgrade_description = "Reduce your overall blood effectiveness, but gain stats when below 50% blood."
	icon = preload("res://00_Assets/00_Sprites/upgrade_icons/blood_minus.png")
	upgrade_number = UpgradeData.LOW_BLOOD_BUFF
	upgrade_scene = self
	type = 0
	pass

func choose_upgrade() -> void:
	super.choose_upgrade()
	GameData.player.blood_effect_low_blood_upgrade_thing *= 1.5
	GameData.player.bb_hitspd *= 0.85
	GameData.player.bb_spd *= 0.85
	return

extends Upgrade

func _init() -> void:
	upgrade_name = "RAGHHH!!!"
	upgrade_description = "Your special produces twice as much blood."
	icon = preload("res://00_Assets/00_Sprites/upgrade_icons/bite_bloody.png")
	upgrade_number = UpgradeData.SP_MORE_BLOOD_CD
	upgrade_scene = self
	type = 3
	pass

func choose_upgrade() -> void:
	super.choose_upgrade()
	#GameData.player.spcd_increase *= 1.3
	GameData.player.sp_blood_mult *= 2.0
	return

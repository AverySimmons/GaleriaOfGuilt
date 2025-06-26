extends Upgrade

func _init() -> void:
	upgrade_name = "RAGHHHH!!!! I NEED BLOOD!" # Maybe WIP name? Idk it's pretty goated
	upgrade_description = "Your special gains more blood, but has a higher cooldown"
	icon = preload("res://00_Assets/00_Sprites/upgrade_icons/boots_super.png")
	upgrade_number = UpgradeData.SP_MORE_BLOOD_CD
	upgrade_scene = self
	pass

func choose_upgrade() -> void:
	super.choose_upgrade()
	GameData.player.spcd_increase *= 1.3
	GameData.player.sp_blood_mult *= 2.0
	return

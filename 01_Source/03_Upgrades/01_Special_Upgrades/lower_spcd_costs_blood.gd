extends Upgrade

func _init() -> void:
	upgrade_name = "Commit Your Everything"
	upgrade_description = "Your special deals double damage, but costs blood."
	icon = preload("res://00_Assets/00_Sprites/upgrade_icons/bite_hollow.png")
	upgrade_number = UpgradeData.SP_DAMAGE_COST_BLOOD
	upgrade_scene = self
	type = 3
	pass

func choose_upgrade() -> void:
	super.choose_upgrade()
	GameData.player.special_damage_increase *= 2
	GameData.player.special_blood_cost = 50
	return

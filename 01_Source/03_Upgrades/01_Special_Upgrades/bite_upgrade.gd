extends Upgrade

func _ready() -> void:
	upgrade_name = "Engulfing Maw"
	upgrade_description = "Replace your special with a bite that provides more blood."
	icon = preload("res://00_Assets/00_Sprites/upgrade_icons/bite_glowing.png")
	upgrade_number = UpgradeData.BITE
	upgrade_scene = self
	pass

func choose_upgrade() -> void:
	super.choose_upgrade()
	var bite_scene = preload("res://03_Components/00_Special_Abilities/bite.tscn")
	# For adding back old special abilities
	var old_ability_scene = UpgradeData.current_ability_class
	UpgradeData.selectable_upgrades.append(old_ability_scene)
	# Set the ability
	GameData.player.set_ability(bite_scene)
	UpgradeData.current_ability_class = upgrade_scene
	return

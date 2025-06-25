extends Upgrade

func _ready() -> void:
	upgrade_name = "Body of Thorns"
	upgrade_description = ""
	icon = preload("res://00_Assets/00_Sprites/upgrade_icons/blood_sword1_super.png")
	upgrade_number = UpgradeData.BITE
	upgrade_scene = UpgradeData.BITE_SCENE
	pass

func choose_upgrade() -> void:
	super.choose_upgrade()
	var bite_scene = preload("res://03_Components/00_Special_Abilities/bite.tscn")
	# For adding back old special abilities
	var old_ability_scene = player.current_ability_scene
	UpgradeData.selectable_upgrades.append(old_ability_scene)
	# Set the ability
	player.set_ability(bite_scene, upgrade_scene)
	return

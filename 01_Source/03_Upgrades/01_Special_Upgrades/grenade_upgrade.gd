extends Upgrade

func _ready() -> void:
	upgrade_name = "Explosive Blood"
	upgrade_description = "Replace your special with a grenade, dealing damage and knockback over a large radius"
	icon = preload("res://00_Assets/00_Sprites/upgrade_icons/blood_sword1_super.png")
	upgrade_number = UpgradeData.GRENADE
	upgrade_scene = self
	pass

func choose_upgrade() -> void:
	super.choose_upgrade()
	var grenade_scene = preload("res://03_Components/00_Special_Abilities/grenade.tscn")
	# For adding back old special abilities
	var old_ability_scene = player.current_ability_scene
	UpgradeData.selectable_upgrades.append(old_ability_scene)
	# Set the ability
	player.set_ability(grenade_scene, upgrade_scene)
	return

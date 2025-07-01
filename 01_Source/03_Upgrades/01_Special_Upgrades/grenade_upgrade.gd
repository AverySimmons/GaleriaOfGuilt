extends Upgrade

func _init() -> void:
	upgrade_name = "Explosive Blood"
	upgrade_description = "Replace your special with a grenade, dealing damage and knockback over a large radius."
	icon = preload("res://00_Assets/00_Sprites/upgrade_icons/blood_sword1_super.png")
	upgrade_number = UpgradeData.GRENADE
	upgrade_scene = self
	type = 3
	pass

func choose_upgrade() -> void:
	super.choose_upgrade()
	var grenade_scene = preload("res://03_Components/00_Special_Abilities/grenade.tscn")
	# For adding back old special abilities
	var old_ability_scene = UpgradeData.current_ability_class
	UpgradeData.selectable_upgrades.append(old_ability_scene)
	# Set the ability
	GameData.player.set_ability(grenade_scene)
	UpgradeData.current_ability_class = upgrade_scene
	GameData.player.current_ability_name = 2
	GameData.overlay.special_cooldown.texture = icon
	return

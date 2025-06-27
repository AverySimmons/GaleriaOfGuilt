extends Upgrade

func _ready() -> void:
	upgrade_name = "Vomit"
	upgrade_description = "Replace your special ability with a shotgun-style attack. Hey guys :D"
	icon = preload("res://00_Assets/00_Sprites/upgrade_icons/blood_sword2_super.png")
	upgrade_number = UpgradeData.SHOTGUN
	upgrade_scene = self
	type = 3
	pass

func choose_upgrade() -> void:
	super.choose_upgrade()
	var shotgun_scene = preload("res://03_Components/00_Special_Abilities/shotgun.tscn")
	# For adding back old special abilities
	var old_ability_scene = UpgradeData.current_ability_class
	UpgradeData.selectable_upgrades.append(old_ability_scene)
	# Set the ability
	GameData.player.set_ability(shotgun_scene)
	UpgradeData.current_ability_class = upgrade_scene
	return

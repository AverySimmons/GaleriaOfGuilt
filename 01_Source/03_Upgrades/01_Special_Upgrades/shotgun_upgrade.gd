extends Upgrade

func _ready() -> void:
	upgrade_name = "Blood Shotgun"
	upgrade_description = "Replace your special ability with a blood shotgun. Hey guys :D"
	icon = preload("res://00_Assets/00_Sprites/upgrade_icons/blood_sword1_super.png")
	upgrade_number = UpgradeData.SHOTGUN
	upgrade_scene = UpgradeData.SHOTGUN_SCENE
	pass

func choose_upgrade() -> void:
	super.choose_upgrade()
	var shotgun_scene = preload("res://03_Components/00_Special_Abilities/shotgun.tscn")
	# For adding back old special abilities
	var old_ability_scene = player.current_ability_scene
	UpgradeData.selectable_upgrades.append(old_ability_scene)
	# Set the ability
	player.set_ability(shotgun_scene, upgrade_scene)
	return

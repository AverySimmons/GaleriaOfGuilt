extends Upgrade

func _init() -> void:
	upgrade_name = "Vomit"
	upgrade_description = "Replace your special ability with a shotgun-style attack. Immediately gain most of your exp back."
	icon = preload("res://00_Assets/00_Sprites/upgrade_icons/shotgun.png")
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
	GameData.player.current_ability_name = 3
	GameData.overlay.special_cooldown.texture = icon
	GameData.player.current_exp = GameData.player.exp_needed * 0.8
	SignalBus.gained_exp.emit()
	return

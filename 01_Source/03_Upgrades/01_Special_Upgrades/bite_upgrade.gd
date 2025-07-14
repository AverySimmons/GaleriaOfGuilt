extends Upgrade

func _init() -> void:
	upgrade_name = "Engulfing Maw"
	upgrade_description = "Replace your special with your orignal bite. Immediately gain most of your exp back."
	icon = preload("res://00_Assets/00_Sprites/upgrade_icons/bite_glowing.png")
	upgrade_number = UpgradeData.BITE
	upgrade_scene = self
	type = 3
	pass

func choose_upgrade() -> void:
	super.choose_upgrade()
	var bite_scene = GameData.player.bite_scene
	GameData.player.set_ability(bite_scene)
	# For adding back old special abilities
	var old_ability_scene = UpgradeData.current_ability_class
	UpgradeData.selectable_upgrades.append(old_ability_scene)
	# Set the ability
	UpgradeData.current_ability_class = upgrade_scene
	GameData.player.current_ability_name = 1
	GameData.overlay.special_cooldown.texture = icon
	GameData.player.current_exp = GameData.player.exp_needed * 0.8
	SignalBus.gained_exp.emit()
	return

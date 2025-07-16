extends Upgrade

func _init() -> void:
	upgrade_name = "Lick Your Talons"
	upgrade_description = "Lose 30% of your max hp, but your swipe attack heals you."
	icon = preload("res://00_Assets/00_Sprites/upgrade_icons/slash_blood.png")
	upgrade_number = UpgradeData.LIFESTEAL
	upgrade_scene = self
	type = 2
	pass

func choose_upgrade() -> void:
	super.choose_upgrade()
	var player = GameData.player
	var percent_hp = player.current_hp/player.max_hp
	player.max_hp *= 0.7
	player.current_hp = player.max_hp*percent_hp
	return

extends Upgrade

func _init() -> void:
	upgrade_name = "Bloodlust"
	upgrade_description = "You have much lower max hp, but your swipe attack heals you."
	icon = preload("res://00_Assets/00_Sprites/upgrade_icons/slash_blood.png")
	upgrade_number = UpgradeData.COSTS_BLOOD_MORE_DMG
	upgrade_scene = self
	pass

func choose_upgrade() -> void:
	super.choose_upgrade()
	var player = GameData.player
	var percent_hp = player.current_hp/player.max_hp
	player.max_hp *= 0.55
	player.current_hp = player.max_hp*percent_hp
	return

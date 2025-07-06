extends Upgrade

func _init() -> void:
	upgrade_name = "Self-Cannibalism" 
	upgrade_description = "At low hp, enter a constant but slightly weaker bloodrage."
	icon = preload("res://00_Assets/00_Sprites/upgrade_icons/blood.png")
	upgrade_number = UpgradeData.LOW_HP_BR
	upgrade_scene = self
	type = 0
	pass

func choose_upgrade() -> void:
	super.choose_upgrade()
	GameData.player.baseline_speed += 90
	return

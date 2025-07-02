extends Upgrade

func _init() -> void:
	upgrade_name = "Body of Thorns"
	upgrade_description = "When you dash through enemies, you deal damage and dash has a slightly longer distance."
	icon = preload("res://00_Assets/00_Sprites/upgrade_icons/dash_sword.png")
	upgrade_number = UpgradeData.DASH_DAMAGE
	upgrade_scene = self
	type = 1
	pass

func choose_upgrade() -> void:
	super.choose_upgrade()
	GameData.player.dash_distance += 75
	return

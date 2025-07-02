extends Upgrade

func _init() -> void:
	upgrade_name = "Insatiable Appetite" 
	upgrade_description = "Your blood effectiveness is increased, but you lose blood more rapidly."
	icon = preload("res://00_Assets/00_Sprites/upgrade_icons/blood_minus.png")
	upgrade_number = UpgradeData.BB_SIZE_INC_LESS_BG
	upgrade_scene = self
	type = 0
	pass

func choose_upgrade() -> void:
	super.choose_upgrade()
	GameData.player.bb_hitspd *= 1.3
	GameData.player.bb_spd *= 1.5
	GameData.player.passive_blood_loss_amount_at_the_above_percentage *= 1.5
	GameData.player.passive_blood_loss_amount_at_max_blood *= 1.5
	return

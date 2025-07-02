extends Upgrade

func _init() -> void:
	upgrade_name = "Endless Void" # STOMACH AS AN EVER-CONSUMING VOID!!!! (Vengeance as a Burning Plague)
	upgrade_description = "Your threshold to passively lose blood is reduced to zero as well as slightly more blood loss, but your blood gain is doubled."
	icon = preload("res://00_Assets/00_Sprites/upgrade_icons/blood_plus.png")
	upgrade_number = UpgradeData.ENDLESS_VOID
	upgrade_scene = self
	type = 0
	pass

func choose_upgrade() -> void:
	super.choose_upgrade()
	GameData.player.bb_multiplier2 *= 2.0
	GameData.player.percentage_to_start_removing_blood_passively = 0
	GameData.player.passive_blood_loss_amount_at_max_blood += 5
	# JOEYGOAT (codeword to add the invisibility thing here... mmm... hemomancer)
	SignalBus.remove_blood_line.emit()
	return

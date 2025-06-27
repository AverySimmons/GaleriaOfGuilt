extends Upgrade

func _init() -> void:
	upgrade_name = "Seeing Red" # GAIN ENERGY EXHAUST, 1(0) ENERGY COST HAHAHAHA
	upgrade_description = "Blood has a stronger effect, but you have less hp."
	icon = preload("res://00_Assets/00_Sprites/upgrade_icons/bite_evil.png")
	upgrade_number = UpgradeData.MORE_BLOOD_EFFECT_LESS_HP
	upgrade_scene = self
	pass

func choose_upgrade() -> void:
	print("Yo")
	super.choose_upgrade()
	print("Yo")
	var player = GameData.player
	player.bb_spd *= 1.5
	player.bb_hitspd *= 1.3334
	var percent_hp = player.current_hp/player.max_hp
	player.max_hp *= 0.6667
	player.current_hp = player.max_hp*percent_hp
	return

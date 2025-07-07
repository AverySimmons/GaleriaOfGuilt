extends Upgrade

func _init() -> void:
	upgrade_name = "I'M STARVING" 
	upgrade_description = "You have less max hp, but killing enemies provides blood."
	icon = preload("res://00_Assets/00_Sprites/upgrade_icons/bite_bloody.png")
	upgrade_number = UpgradeData.KILLS_GAIN_BLOOD_LESS_HP
	upgrade_scene = self
	type = 0
	pass

func choose_upgrade() -> void:
	super.choose_upgrade()
	var player = GameData.player
	var percent_hp = player.current_hp/player.max_hp
	player.max_hp *= 0.75
	player.current_hp = player.max_hp*percent_hp
	player.get_signal_upgrade("kill_blood_gain")
	return

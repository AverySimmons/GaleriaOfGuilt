extends Control

@onready var blood_bar: Sprite2D = $BloodBar
@onready var fill: Sprite2D = $HealthBar/Fill

func _process(delta: float) -> void:
	var fill_perc = GameData.player.current_hp / GameData.player.max_hp
	fill.material.set_shader_parameter("fill_percent", fill_perc)
	
	var fill_perc2 = GameData.player.blood_bar / GameData.player.bb_max
	blood_bar.material.set_shader_parameter("fill_percent", fill_perc2)

extends Control

@onready var blood_vignette: ColorRect = $BloodVignette
@onready var blood_bar: Sprite2D = $BloodBar
@onready var hp_fill: Sprite2D = $HealthBar/Fill
@onready var xp_fill: Sprite2D = $XPBar/Fill
@onready var blood_meter_marker: Sprite2D = $BloodBar/BloodMeterMarker
@onready var special_cooldown: Sprite2D = $SpecialCooldown
@onready var special_progress: TextureProgressBar = $SpecialCooldownProgress

var bb_tween: Tween
var hp_tween: Tween

func _ready() -> void:
	GameData.player.burst_begin.connect(enter_burst)
	GameData.player.burst_end.connect(exit_burst)
	SignalBus.gained_exp.connect(xp_change)
	SignalBus.hp_change.connect(health_change)
	SignalBus.bb_change.connect(blood_change)
	SignalBus.remove_blood_line.connect(remove_blood_meter_marker)
	if UpgradeData.upgrades_gained[UpgradeData.ENDLESS_VOID]:
		remove_blood_meter_marker()
	
	var xp_fill_perc = GameData.player.current_exp / GameData.player.exp_needed
	xp_fill.material.set_shader_parameter("fill_percent", xp_fill_perc)
	
	hp_fill.material.set_shader_parameter("fill_percent", 1)
	blood_bar.material.set_shader_parameter("fill_percent", 0)
	
	GameData.overlay = self

func _process(delta: float) -> void:
	var ratio: float = clamp((GameData.player.special_ability_timer/GameData.player.actual_special_cooldown)*100, 0.0, 100.0)
	special_progress.value = ratio
	#print(special_progress.value)
	pass

func remove_blood_meter_marker():
	blood_meter_marker.visible = false

func enter_burst() -> void:
	var t = create_tween()
	t.tween_property(blood_vignette, "material:shader_parameter/pink_mix", 1, 0.2)
	var t2 = create_tween()
	t2.tween_property(blood_bar, "material:shader_parameter/pink_mix", 1, 0.2)

func exit_burst() -> void:
	var t = create_tween()
	t.tween_property(blood_vignette, "material:shader_parameter/pink_mix", 0, 0.2)
	var t2 = create_tween()
	t2.tween_property(blood_bar, "material:shader_parameter/pink_mix", 0, 0.2)

func xp_change() -> void:
	var fill_perc = GameData.player.current_exp / GameData.player.exp_needed
	var t = create_tween()
	t.tween_property(xp_fill, "material:shader_parameter/fill_percent", fill_perc, 0.25)

func health_change() -> void:
	var fill_perc = GameData.player.current_hp / float(GameData.player.max_hp)
	var cur_fill: float = hp_fill.material.get_shader_parameter("fill_percent")
	if hp_tween: hp_tween.kill()
	hp_tween = create_tween()
	hp_tween.tween_method(health_bar_update_helper, cur_fill, fill_perc, 0.25)

func blood_change() -> void:
	var fill_perc = GameData.player.blood_bar / float(GameData.player.bb_max)
	var cur_fill: float = blood_bar.material.get_shader_parameter("fill_percent")
	if bb_tween: bb_tween.kill()
	bb_tween = create_tween()
	bb_tween.tween_method(blood_bar_update_helper, cur_fill, fill_perc, 0.25)
	
	var vignette_perc = max(0, GameData.player.blood_bar / GameData.player.bb_max - 0.6) / 0.4
	var t2 = create_tween()
	t2.tween_property(blood_vignette, "material:shader_parameter/strength", vignette_perc, 0.25)

func blood_bar_update_helper(val):
	blood_bar.material.set_shader_parameter("fill_percent", val)

func health_bar_update_helper(val):
	hp_fill.material.set_shader_parameter("fill_percent", val)

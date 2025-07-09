extends Control

@export var noise: FastNoiseLite

@onready var blood_vignette: ColorRect = $BloodVignette
@onready var blood_bar: Sprite2D = $BloodBar
@onready var hp_fill: Sprite2D = $HealthBar/Fill
@onready var xp_bar: Sprite2D = $XPBar
@onready var xp_fill: Sprite2D = $XPBar/Fill
@onready var blood_meter_marker: Sprite2D = $BloodBar/BloodMeterMarker
@onready var special_cooldown: Sprite2D = $SpecialCooldown
@onready var special_progress: TextureProgressBar = $SpecialCooldownProgress
@onready var health_bar: Sprite2D = $HealthBar
@onready var boss_health_bar: Sprite2D = $BossHealthBar
@onready var boss_health_bar_fill: Sprite2D = $BossHealthBar/Fill

var tot_time = 0

var shake_timer = 0
var shake_time = 0.75
@onready var hp_bar_start_pos = health_bar.global_position

var bb_tween: Tween
var hp_tween: Tween

var boss_health_updated = true
var boss_health_update_window = 1
var boss_health_update_timer = 0

func _ready() -> void:
	GameData.player.burst_begin.connect(enter_burst)
	GameData.player.burst_end.connect(exit_burst)
	SignalBus.gained_exp.connect(xp_change)
	SignalBus.hp_change.connect(health_change)
	SignalBus.bb_change.connect(blood_change)
	SignalBus.remove_blood_line.connect(remove_blood_meter_marker)
	SignalBus.boss_health_changed.connect(boss_health_changed)
	if UpgradeData.upgrades_gained[UpgradeData.ENDLESS_VOID]:
		remove_blood_meter_marker()
	special_cooldown.texture = UpgradeData.current_ability_class.icon
	
	var xp_fill_perc = GameData.player.current_exp / GameData.player.exp_needed
	xp_fill.material.set_shader_parameter("fill_percent", xp_fill_perc)
	
	hp_fill.material.set_shader_parameter("fill_percent", 1)
	blood_bar.material.set_shader_parameter("fill_percent", 0)
	
	GameData.overlay = self

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("left"):
		boss_health_changed(0.5)
	var ratio: float = clamp((GameData.player.special_ability_timer/GameData.player.actual_special_cooldown)*100, 0.0, 100.0)
	special_progress.value = ratio
	#print(special_progress.value)
	health_bar.global_position = hp_bar_start_pos + Vector2(noise.get_noise_1d(tot_time * 1500), \
								noise.get_noise_1d(tot_time*1500+100)) * shake_timer * 30
	
	tot_time += delta
	shake_timer = move_toward(shake_timer, 0, delta)
	
	$Label.visible = GameData.is_escaping
	
	if not boss_health_updated:
		boss_health_update_timer -= delta
		if boss_health_update_timer < 0:
			boss_health_updated = true
			var val = boss_health_bar_fill.material.get_shader_parameter("fill_percent")
			var t = create_tween()
			t.tween_property(boss_health_bar_fill, "material:shader_parameter/fill2_percent", val, 0.5)

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

func health_change(is_damage: bool) -> void:
	if is_damage:
		shake_timer = shake_time
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

func hide_xp():
	xp_bar.visible = false

func show_boss_health_bar():
	boss_health_bar.visible = true

func boss_health_changed(val):
	var t = create_tween()
	t.tween_property(boss_health_bar_fill, "material:shader_parameter/fill_percent", val, 0.1)
	
	boss_health_update_timer = boss_health_update_window
	boss_health_updated = false

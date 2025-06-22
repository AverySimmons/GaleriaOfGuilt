extends SpecialAbility

@onready var parent = get_parent()
var is_active: bool = false
var active_time: float = 0.6
var active_timer: float
var hit_enemies: Dictionary = {}
var enemies_just_entered: Array
var blood_gain_multiplier: float = 2.5
var attack_slowdown: float = 0.2
var attack_slowdown_actual: float = 1.0
var flinch_amount: float = 0.3


func _ready() -> void:
	super._ready()
	damage = 50
	cooldown = 4
	chargeup = 0.3
	
	connect("area_entered", Callable(self, "_on_area_entered"))
	pass

func _physics_process(delta: float) -> void:
	if !is_active:
		return
	for enemy in enemies_just_entered:
		if enemy is not Enemy || hit_enemies.has(enemy):
			continue
		parent.blood_bar += parent.bb_hit * blood_gain_multiplier
		hit_enemies[enemy] = null
		enemy.take_damage(damage, flinch_amount)
	enemies_just_entered.clear()
	
	active_timer = move_toward(active_timer, 0, delta)
	if active_timer <= 0:
		is_active = false	
		hit_enemies.clear()
	pass


func use_ability(mouse_position: Vector2) -> void:
	super.use_ability(mouse_position)
	active_timer = active_time
	
	if has_overlapping_areas():
		parent.dealt_damage_took_damage = true
	
	var enemies_hit = get_overlapping_areas()
	for enemy in enemies_hit:
		if enemy is not Enemy:
			continue
		parent.blood_bar += parent.bb_hit * blood_gain_multiplier
		hit_enemies[enemy] = null
		enemy.take_damage(damage, flinch_amount)
	return

func _on_area_entered(area: Area2D) -> void:
	enemies_just_entered.append(area)
	pass

extends Area2D

@onready var slash: Sprite2D = $Slash
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

@onready var parent: CharacterBody2D = get_parent()
var is_active: bool = false
var active_time: float = 0.5
var active_timer: float
var hit_enemies: Dictionary = {}
var enemies_just_entered: Array
var damage: float = 20
var attack_slowdown: float = 0.4
var attack_slowdown_actual: float = 1.0
var flinch_amount: float = 0.2

func _ready() -> void:
	connect("area_entered", Callable(self, "_on_area_entered"))
	monitoring = false
	pass

func _physics_process(delta: float) -> void:
	if !is_active:
		return
	for enemy in enemies_just_entered:
		if enemy is not Enemy || hit_enemies.has(enemy):
			continue
		parent.blood_bar += parent.bb_hit
		hit_enemies[enemy] = null
		enemy.take_damage(damage, flinch_amount, 0)
		# Enemy take damage thing
	enemies_just_entered.clear()
	
	active_timer = move_toward(active_timer, 0, delta)
	if active_timer <= 0:
		parent.using_attack_or_special_or_dash = false
		monitoring = false
		is_active = false
		hit_enemies.clear()
		attack_slowdown_actual = 1.0
	pass

func initiate_attack() -> void:
	# Animations:
	# Enemies flash red - In enemy take damage thing
	# Animation player stuff
	# Audio
	var mouse_pos: Vector2 = get_global_mouse_position()
	var direction: Vector2 = parent.global_position.direction_to(mouse_pos)
	var angle: float = direction.angle()
	
	collision_shape_2d.rotation = angle
	
	slash.global_position = parent.global_position + direction * 150
	var abs_dir_ang = Vector2(abs(direction.x), direction.y).angle()
	slash.rotation = abs_dir_ang
	if direction.x < 0:
		slash.scale.x = 1
		slash.rotation *= -1
	else:
		slash.scale.x = -1
	
	
	animation_player.play("blood_swipe")
	
	# Make player face direction of swing
	
	
	active_timer = active_time * parent.bb_hitspd_inc
	attack_slowdown_actual = attack_slowdown
	is_active = true
	monitoring = true
	parent.using_attack_or_special_or_dash = true
	
	if has_overlapping_areas():
		parent.dealt_damage_took_damage = true
	
	var enemies_hit = get_overlapping_areas()
	for enemy in enemies_hit:
		if enemy is not Enemy:
			continue
		parent.blood_bar += parent.bb_hit
		hit_enemies[enemy] = null
		enemy.take_damage(damage, flinch_amount, 0)
	# Functions:
	# Deal dmg
	# Gain blood for each enemy hit and killed
	return

func _on_area_entered(area: Area2D) -> void:
	enemies_just_entered.append(area)
	pass

class_name Door
extends Area2D

@export var direction: Vector2 = Vector2.ZERO
@onready var player_spawn: Marker2D = $PlayerSpawn
@onready var top_sprite: Sprite2D = $Sprite2D
@onready var bot_sprite: Sprite2D = $Sprite2D2


var stair_sprite = preload("res://00_Assets/00_Sprites/Room_sprites/stairs_tileset.png")

var is_stair = false
var is_top = false

var is_locked = false

signal exit(dir: Vector2)

func _physics_process(delta: float) -> void:
	if has_overlapping_areas() and not is_locked:
		exit.emit(direction)

func setup_sprite():
	if is_stair:
		top_sprite.texture = stair_sprite
		bot_sprite.texture = stair_sprite
	
	if is_top:
		top_sprite.frame = 0
		bot_sprite.frame = 1
		bot_sprite.rotation = PI

func lock():
	var t = create_tween()
	t.tween_property($Lock, "modulate", Color(1,1,1,1), 0.2)
	is_locked = true

func unlock():
	var t = create_tween()
	t.tween_property($Lock, "modulate", Color(1,1,1,0), 0.2)
	$UnlockSound.play()
	await get_tree().create_timer(0.4, false).timeout
	is_locked = false

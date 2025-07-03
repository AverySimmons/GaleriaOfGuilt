extends Sprite2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var enemy: Enemy
var entities_node: Node2D
var spawn_time: float = 1

func _ready() -> void:
	match enemy.type:
		"Locust":
			pass
		"Worm":
			scale *= 1.5
		"Lizard":
			scale *= 2
	
	await get_tree().create_timer(randf_range(0, 0.2), false).timeout
	animation_player.speed_scale = 1 / spawn_time
	$AnimationPlayer.play("default")
	if !is_inside_tree(): return
	get_tree().create_timer(spawn_time, false).timeout.connect(spawn, ConnectFlags.CONNECT_DEFERRED)

func spawn() -> void:
	enemy.global_position = global_position
	entities_node.add_child(enemy)

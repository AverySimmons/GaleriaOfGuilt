extends Enemy

@onready var navigation = $NavigationAgent2D
@onready var hurtbox: Area2D = $Hurtbox

func _init() -> void:
	type = "Locust"

func _ready() -> void:
	super._ready()
	if upgraded:
		AudioData.play_sound("enemy_transform", $EnemyTransform)

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	#deal damage to player
	if not death_state and hurtbox.monitoring:
		var overlapping_areas = $Hitbox.get_overlapping_areas()
		if overlapping_areas:
			var player : Player = overlapping_areas[0].owner
			player.take_damage(15)
		

func _process(delta: float) -> void:
	if $Sprite2D.scale.y < 0:
		$Sprite2D/Shadow.position = Vector2(3.333, -163.333)
	else:
		$Sprite2D/Shadow.position = Vector2(3.333, 180)

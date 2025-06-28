extends Enemy

@onready var navigation = $NavigationAgent2D

func _ready() -> void:
	super._ready()
	type = "Locust"

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	

func _process(delta: float) -> void:
	if $Sprite2D.scale.y < 0:
		$Sprite2D/Shadow.position = Vector2(3.333, -163.333)
	else:
		$Sprite2D/Shadow.position = Vector2(3.333, 180)

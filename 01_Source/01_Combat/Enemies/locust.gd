extends Enemy

@onready var navigation = $NavigationAgent2D

func _ready() -> void:
	super._ready()
	type = "Locust"

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	

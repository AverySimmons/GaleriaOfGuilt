extends Enemy

@onready var navigation = $NavigationAgent2D

func _ready() -> void:
	super._ready()
	type = "Lizard"

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	

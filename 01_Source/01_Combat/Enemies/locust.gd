extends Enemy

@onready var navigation = $NavigationAgent2D

func _ready() -> void:
	super._ready()

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	##flip sprite veritcally
	#if going_up:
		#if sprite.scale.y > 0: #facing down
			#sprite.scale.y *= -1
			#going_up = false
			#going_down = true
			#
	#elif going_down:
		#if sprite.scale.y < 0:
			#sprite.scale.y *= -1
			#going_up = true
			#going_down = false
	#else: #not going up or down
		#if sprite.scale.y < 0:
			#sprite.scale.y *= -1
			#going_up = true
			#going_down = false

extends SpecialAbility

var blood_gain_multiplier: float = 2.5
var slowdown: float = 0.4

func _ready() -> void:
	super._ready()
	damage = 50
	cooldown = 4
	chargeup = 0.4
	pass


func use_ability(mouse_position: Vector2) -> void:
	super.use_ability(mouse_position)
	return

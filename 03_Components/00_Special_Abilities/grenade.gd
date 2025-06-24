extends SpecialAbility

var knockback_amount: float = 50

func _ready() -> void:
	super._ready()
	damage = 60
	cooldown = 5
	chargeup = 0.3
	active_time = 0.1
	special_slowdown = 0.5
	flinch_amount = 0.5
	chargeup_slowdown = 0.4
	pass

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	pass

func use_ability() -> void:
	super.use_ability()
	return

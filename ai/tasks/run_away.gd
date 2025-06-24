@tool
extends BTAction

## variables at the top

func _generate_name() -> String:
	return 'run directly away from the player'
	
func _setup() -> void:
	pass
	
func _enter() -> void:
	pass
	
func _tick(delta: float) -> Status:
	return FAILURE
	
## think about helper functions down here

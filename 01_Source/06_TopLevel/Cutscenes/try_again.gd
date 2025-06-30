extends RichTextLabel

func _on_mouse_entered() -> void:
	text = "[rainbow freq=1.0 sat=0.8 val=0.8 speed=1.0]Try Again?[/rainbow]"

func _on_mouse_exited() -> void:
	text = "Try Again?"

extends CanvasLayer

signal try_again()

func _on_button_pressed() -> void:
	try_again.emit()
	$Node2D/AnimationPlayer.play("fade_out")
	SignalBus.unpause.emit()
	await $Node2D/AnimationPlayer.animation_finished
	queue_free()

extends CanvasLayer

signal try_again()

func _ready() -> void:
	var t = create_tween()
	t.tween_property($Static, "volume_db", 0, 1)
	var t2 = create_tween()
	t2.tween_property(GameData.music_event, "volume", 0 , 1)

func _on_button_pressed() -> void:
	var t = create_tween()
	t.tween_property(GameData.music_event, "volume", 0.35 , 0.8)
	var t2 = create_tween()
	t2.tween_property($Static, "volume_db", -30, 0.8)
	
	$ButtonClick.play()
	try_again.emit()
	$Node2D/AnimationPlayer.play("fade_out")
	await $Node2D/AnimationPlayer.animation_finished
	SignalBus.unpause.emit()
	queue_free()

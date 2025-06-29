extends Node

const MAX_SOUNDFX_AMT: int = 16
const INDIVIDUAL_MAX_AMT: int = 4

var cur_total: int = 0
var locust_atk_amt: int = 0

func play_sound(sound_name: String, sound) -> void:
	match sound_name:
		"locust_attack":
			if cur_total < MAX_SOUNDFX_AMT && locust_atk_amt < INDIVIDUAL_MAX_AMT:
				sound.play()
				locust_atk_amt += 1
				cur_total += 1
				await get_tree().create_timer(sound.stream.get_stream(0).get_length()).timeout
				cur_total -= 1
				locust_atk_amt -= 1
	return

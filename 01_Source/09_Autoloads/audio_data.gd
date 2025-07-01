extends Node

const MAX_SOUNDFX_AMT: int = 16
const INDIVIDUAL_MAX_AMT: int = 4

var cur_total: int = 0
var locust_atk_amt: int = 0
var worm_atk_amt: int = 0
var swipe_amt: int = 0
var bite_amt: int = 0
var grenade_throw_amt: int = 0
var shotgun_amt: int = 0
var dash_amt: int = 0
var enemy_hit_amt: int = 0
var enemy_death_amt: int = 0
var explosion_sound: int = 0
var player_hit: int

func play_sound(sound_name: String, sound) -> void:
	if sound == null:
		return
	match sound_name:
		"locust_attack":
			if cur_total < MAX_SOUNDFX_AMT && locust_atk_amt < INDIVIDUAL_MAX_AMT:
				sound.play()
				locust_atk_amt += 1
				cur_total += 1
				await get_tree().create_timer(sound.stream.get_stream(0).get_length()).timeout
				cur_total -= 1
				locust_atk_amt -= 1
		"sand_shot":
			if cur_total < MAX_SOUNDFX_AMT && worm_atk_amt < INDIVIDUAL_MAX_AMT:
				sound.play()
				worm_atk_amt += 1
				cur_total += 1
				await get_tree().create_timer(sound.stream.get_stream(0).get_length()).timeout
				cur_total -= 1
				worm_atk_amt -= 1
		"swipe":
			if swipe_amt < INDIVIDUAL_MAX_AMT:
				sound.play()
				swipe_amt += 1
				cur_total += 1
				await get_tree().create_timer(sound.stream.get_stream(0).get_length()).timeout
				cur_total -= 1
				swipe_amt -= 1
		"bite":
			if bite_amt < INDIVIDUAL_MAX_AMT:
				sound.play()
				bite_amt += 1
				cur_total += 1
				await get_tree().create_timer(sound.stream.get_stream(0).get_length()).timeout
				cur_total -= 1
				bite_amt -= 1
		"grenade_throw":
			if grenade_throw_amt < INDIVIDUAL_MAX_AMT:
				sound.play()
				grenade_throw_amt += 1
				cur_total += 1
				await get_tree().create_timer(sound.stream.get_stream(0).get_length()).timeout
				cur_total -= 1
				grenade_throw_amt -= 1
		"shotgun":
			if shotgun_amt < INDIVIDUAL_MAX_AMT:
				sound.play()
				shotgun_amt += 1
				cur_total += 1
				await get_tree().create_timer(sound.stream.get_stream(0).get_length()).timeout
				cur_total -= 1
				shotgun_amt -= 1
		"dash":
			if dash_amt < INDIVIDUAL_MAX_AMT:
				sound.play()
				dash_amt += 1
				cur_total += 1
				await get_tree().create_timer(sound.stream.get_stream(0).get_length()).timeout
				cur_total -= 1
				dash_amt -= 1
		"enemy_hit":
			if cur_total < MAX_SOUNDFX_AMT && enemy_hit_amt < INDIVIDUAL_MAX_AMT:
				sound.play()
				enemy_hit_amt += 1
				cur_total += 1
				await get_tree().create_timer(sound.stream.get_stream(0).get_length()).timeout
				cur_total -= 1
				enemy_hit_amt -= 1
		"enemy_death":
			if cur_total < MAX_SOUNDFX_AMT && enemy_death_amt < INDIVIDUAL_MAX_AMT:
				sound.play()
				enemy_death_amt += 1
				cur_total += 1
				await get_tree().create_timer(sound.stream.get_stream(0).get_length()).timeout
				cur_total -= 1
				enemy_death_amt -= 1
		"grenade_explosion":
			if explosion_sound < INDIVIDUAL_MAX_AMT:
				sound.play()
				explosion_sound += 1
				cur_total += 1
				await get_tree().create_timer(sound.stream.get_stream(0).get_length()).timeout
				cur_total -= 1
				explosion_sound -= 1
		"player_hit":
			if cur_total < MAX_SOUNDFX_AMT && player_hit < INDIVIDUAL_MAX_AMT:
				sound.play()
				player_hit += 1
				cur_total += 1
				await get_tree().create_timer(sound.stream.get_stream(0).get_length()).timeout
				cur_total -= 1
				player_hit -= 1
	return

extends Node2D

const blood_splash_amount = 10
const blood_pool_amount = 15

func enemy_hit(pos: Vector2, dir: Vector2):
	for i in blood_splash_amount:
		var ang = dir.angle() + randfn(0, PI / 4)
		var speed = randfn(3000, 1000)
		SignalBus.spawn_blood.emit(pos, speed * Vector2.from_angle(ang))
	
	for i in blood_pool_amount:
		var ang = dir.angle() + randfn(0, PI / 2)
		var speed = randfn(400, 200)
		SignalBus.spawn_blood.emit(pos, speed * Vector2.from_angle(ang))

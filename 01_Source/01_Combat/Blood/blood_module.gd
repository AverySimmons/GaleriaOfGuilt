extends Node2D

const blood_splash_amount = 5
const blood_pool_amount = 10

func enemy_hit(pos: Vector2, dir: Vector2):
	for i in blood_splash_amount:
		var ang = dir.angle() + randfn(0, PI / 8)
		var speed = randfn(1500, 200)
		SignalBus.spawn_blood.emit(pos, speed * Vector2.from_angle(ang))
	
	for i in blood_pool_amount:
		var ang = dir.angle() + randfn(0, PI / 8)
		var speed = randfn(300, 100)
		SignalBus.spawn_blood.emit(pos, speed * Vector2.from_angle(ang))

extends Node2D

const blood_splash_amount = 7
const blood_pool_amount = 15

const death_amount = 30

func enemy_hit(pos: Vector2, dir: Vector2):
	for i in blood_splash_amount:
		var ang = dir.angle() + randfn(0, 0.5)
		var speed = randfn(2500, 1000)
		SignalBus.spawn_blood.emit(pos, speed * Vector2.from_angle(ang))
	
	for i in blood_pool_amount:
		var ang = dir.angle() + randfn(0, 1)
		var speed = randfn(400, 200)
		SignalBus.spawn_blood.emit(pos, speed * Vector2.from_angle(ang))

func enemy_death(pos: Vector2):
	for i in blood_pool_amount:
		var ang = randf() * TAU
		var speed = randfn(400, 300)
		SignalBus.spawn_blood.emit(pos, speed * Vector2.from_angle(ang))

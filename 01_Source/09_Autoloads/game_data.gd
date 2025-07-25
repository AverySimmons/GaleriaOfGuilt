extends Node

const DIRECTIONS = {
	Vector2.RIGHT : 0,
	Vector2.UP : 1,
	Vector2.LEFT : 2,
	Vector2.DOWN : 3
}

const INVERSE_DIRECTIONS = {
	0 : Vector2.RIGHT,
	1 : Vector2.UP,
	2 : Vector2.LEFT,
	3 : Vector2.DOWN
}

var player: Player

var music_event: FmodEventEmitter2D

var mall_ind: int = 0

var is_escaping = false

var overlay

var boss_fight_offset: Vector2

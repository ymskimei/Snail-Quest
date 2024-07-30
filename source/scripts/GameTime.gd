extends Node

var game_day: int = 0
var game_time: float = 0.0
var modifier: float = 1.0

func _ready() -> void:
	SnailQuest.set_game_time(self)

func _physics_process(delta: float) -> void:
	game_time += delta * modifier
	if (game_time >= (60 * 24)):
		game_time = 0.0
		game_day += 1

func set_raw_time(new_time: float) -> void:
	game_time = new_time

func get_raw_time() -> float:
	return game_time

func set_time_speed(value: float = 1.0) -> void:
	modifier = value

func get_time_speed() -> float:
	return modifier

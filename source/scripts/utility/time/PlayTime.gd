extends Node

var time_start: int = 0
var previous_time: int = 0
var played_time: int = 0

func _ready() -> void:
	Auto.set_play_time(self)
	_reset_start()

func _process(_delta: float) -> void:
	_calculate_play_time()

func _reset_start() -> void:
	time_start = Time.get_ticks_msec()

func _calculate_play_time() -> void:
	played_time = (Time.get_ticks_msec() - time_start) + previous_time;

func set_raw_time(new_time: int) -> void:
	played_time = new_time

func get_raw_time() -> int:
	return played_time

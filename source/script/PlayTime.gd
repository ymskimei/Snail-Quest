extends Node

var time_start: int = 0
var previous_time: int = 0
var played_time: int = 0

func _ready() -> void:
	SnailQuest.set_play_time(self)
	_reset_start()

func _process(_delta: float) -> void:
	_calculate_play_time()

func _reset_start() -> void:
	time_start = Time.get_ticks_msec()

func _calculate_play_time() -> void:
	played_time = previous_time + (Time.get_ticks_msec() - time_start);

func reset_time_to(new_time: int) -> void:
	previous_time = new_time
	played_time = 0

func get_total_time() -> int:
	return played_time

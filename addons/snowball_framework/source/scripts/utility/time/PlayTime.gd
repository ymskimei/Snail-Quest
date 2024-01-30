extends Node

var played_time: int = 0
var time_start
var previous_time: int = 0

func _ready() -> void:
	reset_start()
	SB.set_play_time(self)

func _process(_delta: float) -> void:
	calculate_play_time()

func reset_start() -> void:
	time_start = Time.get_ticks_msec()
 
func calculate_play_time() -> void:
	played_time = (Time.get_ticks_msec() - time_start) + previous_time;

func time_converted() -> Array:
	var s = played_time / 1000 % 60
	var m = (played_time / 1000 / 60) % 60
	var h = (played_time / 1000 / 60) / 60
	return [h, m, s]

func get_time() -> String:
	var time = time_converted()
	return "%02dh, %02dm, %02ds" % [time[0], time[1], time[2]]

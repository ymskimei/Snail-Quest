extends Node

var game_time: int = 0
export var second_speed = 1

func _ready() -> void:
	var second_timer = Timer.new()
	second_timer.set_timer_process_mode(1)
	second_timer.set_wait_time(second_speed)
	second_timer.connect("timeout", self, "on_unpaused_second")
	add_child(second_timer)
	second_timer.start()
	Auto.set_game_time(self)

func time_converted(hour24: bool) -> Array:
	var hour = int(game_time / 60)
	var minute = game_time % 60
	var period = "AM" 
	if hour24: 
		return [hour, minute, ""]
	#else
	if hour >= 12:
		hour = hour % 12
		period = "PM"
	if hour == 0: 
		hour = 12
	return [hour, minute, period]

func on_unpaused_second() -> void:
	game_time += 1
	if (game_time >= (60 * 24)):
		game_time = 0

func get_raw_time() -> int:
	return game_time

func get_time(hour_24: bool) -> String:
	var time = time_converted(hour_24)
	return "%02d:%02d" % [time[0], time[1]] + time[2]

func set_time(new_time: int) -> void:
	game_time = new_time

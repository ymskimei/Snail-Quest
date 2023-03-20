extends Node

# Game time in minutes
var game_time:int = 0

func _ready():
	var second_timer = Timer.new()
	second_timer.set_timer_process_mode(1)
	second_timer.set_wait_time(1)
	second_timer.connect("timeout", self, "on_unpaused_second")
	add_child(second_timer)
	second_timer.start()

func time_converted(hour24):
	var hour = game_time / 60 as int
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

func on_unpaused_second():
	game_time += 1
	if (game_time >= (60 * 24)):
		game_time = 0

func get_time(hour24):
	var time = time_converted(hour24)
	return "%02d:%02d" % [time[0], time[1]] + time[2] 

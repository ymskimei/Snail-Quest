extends Node

var game_time = "0"
var play_time = "0"
var time_start = 0
var time_elapsed = 0
var minute = 0
var hour = 0
var midday = "AM"

func _ready():
	set_time_start()
	second_timer()

func _process(delta):
	pass
	
func set_time_start():
	time_start = OS.get_unix_time()

func time_elapsed():
	time_elapsed = OS.get_unix_time() - time_start

func time_converted(time_elapsed):
	var second = time_elapsed % 60
	var minute = (time_elapsed / 60) % 60
	var hour = (time_elapsed / 60) / 60
	return [hour, minute, second]

func clock_converted(time_elapsed):
	minute += 1
	if minute > 60:
		minute = 0
		hour += 1
	if hour > 13:
		hour = 0
		if midday == "AM":
			midday = "PM"
		else:
			midday = "AM"
	return [hour, minute, midday]

func second_timer():
	var second_timer = Timer.new()
	second_timer.set_wait_time(1)
	second_timer.connect("timeout", self, "on_second_timeout")
	add_child(second_timer)
	second_timer.start()

func on_second_timeout():
	time_elapsed()
	var time = time_converted(time_elapsed)
	var clock = clock_converted(time_elapsed)
	play_time = "%02dh, %02dm, %02ds" % [time[0], time[1], time[2]]
	game_time = "%02d:%02d" % [clock[0], clock[1]] + clock[2] 

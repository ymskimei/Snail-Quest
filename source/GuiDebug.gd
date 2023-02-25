extends CanvasLayer

onready var display_framerate = $MarginContainer/VBoxContainer/DisplayFramerate
onready var display_world_clock = $MarginContainer/VBoxContainer/DisplayWorldClock
onready var display_play_time = $MarginContainer/VBoxContainer/DisplayPlayTime
export var framerate_normal = 60
export var framerate_low = 30

func _process(_delta):
	var framerate = Engine.get_frames_per_second()
	var world_time = WorldClock.game_time
	var play_time = WorldClock.play_time
	if framerate < framerate_low:
		display_framerate.set_bbcode(" [color=#EA6A59]" + str(framerate))
	elif framerate < framerate_normal:
		display_framerate.set_bbcode(" [color=#EDDB65]" + str(framerate))
	else:
		display_framerate.set_bbcode(" [color=#C3EF5D]" + str(framerate))
	display_world_clock.set_bbcode(" [color=#C3EF5D]" + str(world_time))
	display_play_time.set_bbcode(" [color=#C3EF5D]" + str(play_time))

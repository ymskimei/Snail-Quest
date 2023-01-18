extends Control

export var framerate_normal = 60
export var framerate_low = 30

func _process(delta):
	var framerate = Engine.get_frames_per_second()
	if framerate < framerate_low:
		$MarginContainer/DisplayFramerate.set_bbcode(" [color=#EA6A59]" + str(framerate))
	elif framerate < framerate_normal:
		$MarginContainer/DisplayFramerate.set_bbcode(" [color=#EDDB65]" + str(framerate))
	else:
		$MarginContainer/DisplayFramerate.set_bbcode(" [color=#C3EF5D]" + str(framerate))

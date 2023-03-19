extends CanvasLayer

var can_pause : bool = true

onready var debug_information = $"%DebugInformation"
onready var display_framerate = $"%DisplayFramerate"
onready var display_world_clock = $"%DisplayWorldClock"
onready var display_play_time = $"%DisplayPlayTime"
onready var command_console = $"%GuiConsole"
export var version_number = "0.1.0-alpha"
export var framerate_normal = 60
export var framerate_low = 30

func _process(_delta):
	var framerate = Engine.get_frames_per_second()
	var world_time = GameTime
	var play_time = PlayTime
	if framerate < framerate_low:
		display_framerate.set_bbcode("[color=#EA6A59]" + str(framerate))
	elif framerate < framerate_normal:
		display_framerate.set_bbcode("[color=#EDDB65]" + str(framerate))
	else:
		display_framerate.set_bbcode("[color=#C3EF5D]" + str(framerate))
	display_world_clock.set_bbcode("[color=#C3EF5D]" + str(world_time.get_time(false)))
	display_play_time.set_bbcode("[color=#C3EF5D]" + str(play_time.get_time()))
	toggle_command_console()

func display_debug_information():
	if debug_information.visible == false:
		debug_information.visible = true
	else:
		debug_information.visible = false

func toggle_command_console():
	if Input.is_action_just_pressed("gui_debug"):
		if can_pause == true:
			get_tree().set_deferred("paused", true)
			command_console.visible = true
			command_console.command_input.grab_focus()
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			if command_console.command_display.bbcode_text == "":
				command_console.welcome_message()
			can_pause = false
		else:
			get_tree().set_deferred("paused", false)
			command_console.visible = false
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			can_pause = true

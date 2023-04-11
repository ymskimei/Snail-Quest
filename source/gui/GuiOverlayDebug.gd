extends CanvasLayer

var can_pause : bool = true

onready var debug_information = $"%DebugInformation"
onready var display_framerate = $"%DisplayFramerate"
onready var display_game_time = $"%DisplayGameTime"
onready var display_play_time = $"%DisplayPlayTime"
onready var display_coordinate = $"%DisplayCoordinate"
onready var command_console = $"%GuiConsole"

func _process(_delta):
	set_display_framerate()
	set_display_world_time()
	set_display_play_time()
	set_display_coordinates()
	toggle_command_console()

func set_display_framerate():
	var framerate = Engine.get_frames_per_second()
	if framerate < 30:
		display_framerate.set_bbcode("[color=#EA6A59]%s" % framerate)
	elif framerate < 60:
		display_framerate.set_bbcode("[color=#EDDB65]%s" % framerate)
	else:
		display_framerate.set_bbcode("[color=#C3EF5D]%s" % framerate)

func set_display_world_time():
	if is_instance_valid(GlobalManager.game_time):
		var game_time = GlobalManager.game_time
		display_game_time.set_bbcode("[color=#C3EF5D]%s" % game_time.get_time(false))
	else:
		display_game_time.set_bbcode("[color=#C3EF5D]??:??")

func set_display_play_time():
	if is_instance_valid(GlobalManager.play_time):
		var play_time = GlobalManager.play_time
		display_play_time.set_bbcode("[color=#C3EF5D]%s" % play_time.get_time())
	else:
		display_play_time.set_bbcode("[color=#C3EF5D]??h, ??m, ??s")

func set_display_coordinates():
	if is_instance_valid(GlobalManager.player):
		var coords = GlobalManager.player.get_coords()
		display_coordinate.set_bbcode("[color=#E7738C]X: %s\n[color=#A3DD5D]Y: %s\n[color=#71B4F6]Z: %s" % [coords[0], coords[1], coords[2]])
	else:
		display_coordinate.set_bbcode("[color=#E7738C]X: ?\n[color=#A3DD5D]Y: ?\n[color=#71B4F6]Z: ?")

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
			command_console.visible = false
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			get_tree().set_deferred("paused", false)
			can_pause = true

func show_debug_information():
	if debug_information.visible == false:
		debug_information.visible = true
	else:
		debug_information.visible = false

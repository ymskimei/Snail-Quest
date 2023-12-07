extends CanvasLayer

var can_pause: bool = true

onready var debug_information: VBoxContainer = $MarginContainer/HBoxContainer/DebugInformation
onready var display_framerate: RichTextLabel = $MarginContainer/HBoxContainer/DebugInformation/DisplayFramerate
onready var display_game_time: RichTextLabel = $MarginContainer/HBoxContainer/DebugInformation/DisplayGameTime
onready var display_play_time: RichTextLabel = $MarginContainer/HBoxContainer/DebugInformation/DisplayPlayTime
onready var display_camera_target: RichTextLabel = $MarginContainer/HBoxContainer/DebugInformation/DisplayCameraTarget
onready var display_controllable: RichTextLabel = $MarginContainer/HBoxContainer/DebugInformation/DisplayControllable
onready var display_controllable_target: RichTextLabel = $MarginContainer/HBoxContainer/DebugInformation/DisplayControllableTarget
onready var display_chunk_coords: RichTextLabel = $MarginContainer/HBoxContainer/DebugInformation/DisplayChunkCoords
onready var display_coordinate: RichTextLabel = $MarginContainer/HBoxContainer/DebugInformation/DisplayCoordinate
onready var command_console: PanelContainer = $MarginContainer/HBoxContainer/ConsoleContainer/GuiConsole

func _process(_delta):
	set_display_framerate()
	set_display_world_time()
	set_display_play_time()
	set_display_camera_target()
	set_display_controllable()
	set_display_controllable_target()
	set_display_chunk_coords()
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
		display_game_time.set_bbcode("[color=#C3EF5D]%s" % GlobalManager.game_time.get_time(false))
	else:
		display_game_time.set_bbcode("[color=#C3EF5D]??:??")

func set_display_play_time():
	if is_instance_valid(GlobalManager.play_time):
		display_play_time.set_bbcode("[color=#C3EF5D]%s" % GlobalManager.play_time.get_time())
	else:
		display_play_time.set_bbcode("[color=#C3EF5D]??h, ??m, ??s")

func set_display_camera_target():
	if is_instance_valid(GlobalManager.camera):
		if is_instance_valid(GlobalManager.camera.cam_target):
			display_camera_target.set_bbcode("[color=#71B4F6]Cam Target: %s" % GlobalManager.camera.cam_target.name)
	else:
		display_camera_target.set_bbcode("[color=#71B4F6]Cam Target: ??")

func set_display_controllable():
	if is_instance_valid(GlobalManager.controllable):
		display_controllable.set_bbcode("[color=#C289FF]Controlling: %s" % GlobalManager.controllable.name)
	else:
		display_controllable.set_bbcode("[color=#C289FF]Controlling: ??")

func set_display_controllable_target():
	if is_instance_valid(GlobalManager.controllable):
		if is_instance_valid(GlobalManager.controllable.target):
			display_controllable_target.set_bbcode("[color=#E7738C]Target: %s" % GlobalManager.controllable.target.name)
	else:
		display_controllable_target.set_bbcode("[color=#E7738C]Target: ??")

func set_display_chunk_coords():
	if is_instance_valid(GlobalManager.controllable):
		var coords_x = floor(GlobalManager.controllable.global_translation.x / GlobalManager.chunk_size)
		var coords_z = floor(GlobalManager.controllable.global_translation.z / GlobalManager.chunk_size)
		display_chunk_coords.set_bbcode("[color=#C289FF]%s, [color=#62BC43]%s" % [coords_x, coords_z])
	elif is_instance_valid(GlobalManager.camera):
		var coords_x = floor(GlobalManager.camera.global_translation.x / GlobalManager.chunk_size)
		var coords_z = floor(GlobalManager.camera.global_translation.z / GlobalManager.chunk_size)
		display_chunk_coords.set_bbcode("[color=#C289FF]%s, [color=#62BC43]%s" % [coords_x, coords_z])
	else:
		display_chunk_coords.set_bbcode("?, ?")

func set_display_coordinates():
	if is_instance_valid(GlobalManager.controllable):
		if GlobalManager.controllable.has_method("get_coords"):
			var coords = GlobalManager.controllable.get_coords()
			display_coordinate.set_bbcode("[color=#E7738C]X: %s\n[color=#A3DD5D]Y: %s\n[color=#71B4F6]Z: %s" % [coords[0], coords[1], coords[2]])
	else:
		display_coordinate.set_bbcode("[color=#E7738C]X: ?\n[color=#A3DD5D]Y: ?\n[color=#71B4F6]Z: ?")

func toggle_command_console():
	if Input.is_action_just_pressed("gui_debug"):
		if can_pause == true:
			open_command_console()
		else:
			close_command_console()

func open_command_console():
	GuiMain.debug_open = true
	get_tree().set_deferred("paused", true)
	command_console.visible = true
	command_console.command_input.grab_focus()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if command_console.command_display.bbcode_text == "":
		command_console.welcome_message()
	can_pause = false

func close_command_console():
	GuiMain.debug_open = false
	command_console.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().set_deferred("paused", false)
	can_pause = true

func show_debug_information():
	if debug_information.visible == false:
		debug_information.visible = true
	else:
		debug_information.visible = false

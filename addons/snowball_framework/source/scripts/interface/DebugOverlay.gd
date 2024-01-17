extends Menu

onready var debug_information: VBoxContainer = $MarginContainer/HBoxContainer/DebugInformation
onready var display_framerate: RichTextLabel = $MarginContainer/HBoxContainer/DebugInformation/DisplayFramerate
onready var display_game_time: RichTextLabel = $MarginContainer/HBoxContainer/DebugInformation/DisplayGameTime
onready var display_play_time: RichTextLabel = $MarginContainer/HBoxContainer/DebugInformation/DisplayPlayTime
onready var display_camera_target: RichTextLabel = $MarginContainer/HBoxContainer/DebugInformation/DisplayCameraTarget
onready var display_controlled: RichTextLabel = $MarginContainer/HBoxContainer/DebugInformation/DisplayControlled
onready var display_controlled_target: RichTextLabel = $MarginContainer/HBoxContainer/DebugInformation/DisplayControlledTarget
onready var display_prev_controlled: RichTextLabel = $MarginContainer/HBoxContainer/DebugInformation/DisplayPrevControlled
onready var display_chunk_coords: RichTextLabel = $MarginContainer/HBoxContainer/DebugInformation/DisplayChunkCoords
onready var display_coordinate: RichTextLabel = $MarginContainer/HBoxContainer/DebugInformation/DisplayCoordinate
onready var command_console: PanelContainer = $MarginContainer/HBoxContainer/ConsoleContainer/GuiConsole

func _ready() -> void:
	default_focus = command_console.command_input
	command_console.welcome_message()

func _process(_delta: float) -> void:
	set_display_framerate()
	set_display_world_time()
	set_display_play_time()
	set_display_camera_target()
	set_display_controlled()
	set_display_controlled_target()
	set_display_prev_controlled()
	set_display_chunk_coords()
	set_display_coordinates()

func set_display_framerate() -> void:
	var framerate = Engine.get_frames_per_second()
	if framerate < 30:
		display_framerate.set_bbcode("[color=#EA6A59]%s" % framerate)
	elif framerate < 60:
		display_framerate.set_bbcode("[color=#EDDB65]%s" % framerate)
	else:
		display_framerate.set_bbcode("[color=#C3EF5D]%s" % framerate)

func set_display_world_time() -> void:
	if is_instance_valid(SB.game_time):
		display_game_time.set_bbcode("[color=#C3EF5D]%s" % SB.game_time.get_time(false))
	else:
		display_game_time.set_bbcode("[color=#C3EF5D]??:??")

func set_display_play_time() -> void:
	if is_instance_valid(SB.play_time):
		display_play_time.set_bbcode("[color=#C3EF5D]%s" % SB.play_time.get_time())
	else:
		display_play_time.set_bbcode("[color=#C3EF5D]??h, ??m, ??s")

func set_display_camera_target() -> void:
	if is_instance_valid(SB.camera):
		if is_instance_valid(SB.camera.target):
			display_camera_target.set_bbcode("[color=#71B4F6]Cam Target: %s" % SB.camera.target.name)
	else:
		display_camera_target.set_bbcode("[color=#71B4F6]Cam Target: ??")

func set_display_controlled() -> void:
	if is_instance_valid(SB.controlled):
		display_controlled.set_bbcode("[color=#C289FF]Controlling: %s" % SB.controlled.name)
	else:
		display_controlled.set_bbcode("[color=#C289FF]Controlling: ??")

func set_display_controlled_target() -> void:
	if is_instance_valid(SB.controlled):
		if SB.controlled is Entity:
			display_controlled_target.set_bbcode("[color=#E7738C]Target: %s" % SB.controlled.target.name)
	else:
		display_controlled_target.set_bbcode("[color=#E7738C]Target: ??")

func set_display_prev_controlled() -> void:
	if is_instance_valid(SB.prev_controlled):
		display_prev_controlled.set_bbcode("[color=#F491FF]Last controlling: %s" % SB.prev_controlled.name)
	else:
		display_prev_controlled.set_bbcode("[color=#F491FF]Last controlling: ??")

func set_display_chunk_coords() -> void:
	if is_instance_valid(SB.controlled):
		var coords_x = floor(SB.controlled.global_translation.x / SB.chunk_size)
		var coords_z = floor(SB.controlled.global_translation.z / SB.chunk_size)
		display_chunk_coords.set_bbcode("[color=#C289FF]%s, [color=#62BC43]%s" % [coords_x, coords_z])
	elif is_instance_valid(SB.camera):
		var coords_x = floor(SB.camera.global_translation.x / SB.chunk_size)
		var coords_z = floor(SB.camera.global_translation.z / SB.chunk_size)
		display_chunk_coords.set_bbcode("[color=#C289FF]%s, [color=#62BC43]%s" % [coords_x, coords_z])
	else:
		display_chunk_coords.set_bbcode("?, ?")

func set_display_coordinates() -> void:
	if is_instance_valid(SB.controlled):
		if SB.controlled.has_method("get_coords"):
			var coords = SB.controlled.get_coords()
			display_coordinate.set_bbcode("[color=#E7738C]X: %s\n[color=#A3DD5D]Y: %s\n[color=#71B4F6]Z: %s" % [coords[0], coords[1], coords[2]])
	else:
		display_coordinate.set_bbcode("[color=#E7738C]X: ?\n[color=#A3DD5D]Y: ?\n[color=#71B4F6]Z: ?")

func set_command_console(toggle: bool) -> void:
	if toggle:
		SB.interface.debug_open = true
		command_console.visible = true
		command_console.command_input.grab_focus()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		if command_console.command_display.bbcode_text == "":
			command_console.welcome_message()
	else:
		SB.interface.debug_open = false
		command_console.visible = false
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func show_debug_information() -> void:
	if debug_information.visible == false:
		debug_information.visible = true
	else:
		debug_information.visible = false

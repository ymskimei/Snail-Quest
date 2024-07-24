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

var default_color: String = RegistryColor.get_bbcode(RegistryColor.light_gray)
var x_color: String = RegistryColor.get_bbcode(RegistryColor.red)
var y_color: String = RegistryColor.get_bbcode(RegistryColor.lime)
var z_color: String = RegistryColor.get_bbcode(RegistryColor.blue)

func _ready() -> void:
	default_focus = command_console.text_input

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
	var framerate: int = int(Engine.get_frames_per_second())
	var color: String = ""
	if framerate < Engine.target_fps / 2:
		color = RegistryColor.red
	elif framerate < Engine.target_fps:
		color = RegistryColor.yellow
	elif framerate > Engine.target_fps:
		color = RegistryColor.green
	else:
		color = RegistryColor.lime
	display_framerate.set_bbcode(RegistryColor.get_bbcode(color) + "%s" % framerate)

func set_display_world_time() -> void:
	if SnailQuest.game_time:
		display_game_time.set_bbcode(default_color + "%s" % Utility.get_time_as_clock(SnailQuest.get_game_time().get_raw_time(), false))
	else:
		display_game_time.set_bbcode(default_color + "??:??")

func set_display_play_time() -> void:
	if SnailQuest.play_time:
		display_play_time.set_bbcode(default_color + "%s" % Utility.get_time_as_count(SnailQuest.get_play_time().get_total_time()))
	else:
		display_play_time.set_bbcode(default_color + "??h, ??m, ??s")

func set_display_camera_target() -> void:
	if SnailQuest.camera:
		if SnailQuest.camera.target:
			display_camera_target.set_bbcode(default_color + "Cam Target: %s" % SnailQuest.camera.target.name)
	else:
		display_camera_target.set_bbcode(default_color + "Cam Target: ??")

func set_display_controlled() -> void:
	if SnailQuest.controlled:
		display_controlled.set_bbcode(default_color + "Controlling: %s" % SnailQuest.controlled.name)
	else:
		display_controlled.set_bbcode(default_color + "Controlling: ??")

func set_display_controlled_target() -> void:
	if is_instance_valid(SnailQuest.controlled):
		if SnailQuest.controlled is Entity and is_instance_valid(SnailQuest.controlled.target):
			display_controlled_target.set_bbcode(default_color + "Target: %s" % SnailQuest.controlled.target.name)
	else:
		display_controlled_target.set_bbcode(default_color + "Target: ??")

func set_display_prev_controlled() -> void:
	if SnailQuest.prev_controlled:
		display_prev_controlled.set_bbcode(default_color + "Last controlling: %s" % SnailQuest.prev_controlled.name)
	else:
		display_prev_controlled.set_bbcode(default_color + "Last controlling: ??")

func set_display_chunk_coords() -> void:
	if SnailQuest.controlled or SnailQuest.camera:
		var e: Spatial = null
		if SnailQuest.controlled:
			e = SnailQuest.controlled
		elif SnailQuest.camera:
			e = SnailQuest.camera
		var coords_x = floor(e.global_translation.x / SnailQuest.chunk_size)
		var coords_z = floor(e.global_translation.z / SnailQuest.chunk_size)
		display_chunk_coords.set_bbcode(x_color + "%s, " % coords_x + z_color + "%s" % coords_z)
	else:
		display_chunk_coords.set_bbcode(x_color + "?, " + z_color + "?")

func set_display_coordinates() -> void:
	if SnailQuest.controlled or SnailQuest.camera:
		var coords: Array = []
		var e: Spatial = null
		if SnailQuest.controlled:
			e = SnailQuest.controlled
		elif SnailQuest.camera:
			e = SnailQuest.camera
		coords = e.get_coords()
		display_coordinate.set_bbcode(x_color + "X: %s\n" % coords[0] + y_color + "Y: %s\n" % coords[1] + z_color + "Z: %s" % coords[2])
	else:
		display_coordinate.set_bbcode(x_color + "X: ?\n" + y_color + "Y: ?\n" + z_color + "Z: ?")

func set_command_console(toggle: bool) -> void:
	if toggle:
		SnailQuest.interface.debug_open = true
		command_console.visible = true
		command_console.command_input.grab_focus()
		Device.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		if command_console.command_display.bbcode_text == "":
			command_console.welcome_message()
	else:
		SnailQuest.interface.debug_open = false
		command_console.visible = false
		Device.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func show_debug_information() -> void:
	if debug_information.visible == false:
		debug_information.visible = true
	else:
		debug_information.visible = false

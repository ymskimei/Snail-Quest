extends Menu

@onready var debug_information: VBoxContainer = $MarginContainer/HBoxContainer/DebugInformation
@onready var display_framerate: RichTextLabel = $MarginContainer/HBoxContainer/DebugInformation/DisplayFramerate
@onready var display_game_time: RichTextLabel = $MarginContainer/HBoxContainer/DebugInformation/DisplayGameTime
@onready var display_play_time: RichTextLabel = $MarginContainer/HBoxContainer/DebugInformation/DisplayPlayTime
@onready var display_camera_target: RichTextLabel = $MarginContainer/HBoxContainer/DebugInformation/DisplayCameraTarget
@onready var display_controlled: RichTextLabel = $MarginContainer/HBoxContainer/DebugInformation/DisplayControlled
@onready var display_controlled_target: RichTextLabel = $MarginContainer/HBoxContainer/DebugInformation/DisplayControlledTarget
@onready var display_prev_controlled: RichTextLabel = $MarginContainer/HBoxContainer/DebugInformation/DisplayPrevControlled
@onready var display_chunk_coords: RichTextLabel = $MarginContainer/HBoxContainer/DebugInformation/DisplayChunkCoords
@onready var display_coordinate: RichTextLabel = $MarginContainer/HBoxContainer/DebugInformation/DisplayCoordinate
@onready var command_console: PanelContainer = $MarginContainer/HBoxContainer/ConsoleContainer/GuiConsole

var default_color: String = RegistryColor.get_text_color(RegistryColor.light_gray)
var x_color: String = RegistryColor.get_text_color(RegistryColor.red)
var y_color: String = RegistryColor.get_text_color(RegistryColor.lime)
var z_color: String = RegistryColor.get_text_color(RegistryColor.blue)

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
	var framerate: int = Engine.get_frames_per_second()
	var color: String = ""
	if framerate < Engine.max_fps / 2:
		color = RegistryColor.red
	elif framerate < Engine.max_fps:
		color = RegistryColor.yellow
	elif framerate > Engine.max_fps:
		color = RegistryColor.green
	else:
		color = RegistryColor.lime
	display_framerate.set_text(RegistryColor.get_text_color(color) + "%s" % framerate)

func set_display_world_time() -> void:
	if SB.game_time:
		display_game_time.set_text(default_color + "%s" % SB.game_time.get_time(false))
	else:
		display_game_time.set_text(default_color + "??:??")

func set_display_play_time() -> void:
	if SB.play_time:
		display_play_time.set_text(default_color + "%s" % SB.play_time.get_time())
	else:
		display_play_time.set_text(default_color + "??h, ??m, ??s")

func set_display_camera_target() -> void:
	if SB.camera:
		if SB.camera.target:
			display_camera_target.set_text(default_color + "Cam Target: %s" % SB.camera.target.name)
	else:
		display_camera_target.set_text(default_color + "Cam Target: ??")

func set_display_controlled() -> void:
	if SB.controlled:
		display_controlled.set_text(default_color + "Controlling: %s" % SB.controlled.name)
	else:
		display_controlled.set_text(default_color + "Controlling: ??")

func set_display_controlled_target() -> void:
	if is_instance_valid(SB.controlled):
		if SB.controlled is Entity and is_instance_valid(SB.controlled.target):
			display_controlled_target.set_text(default_color + "Target: %s" % SB.controlled.target.name)
	else:
		display_controlled_target.set_text(default_color + "Target: ??")

func set_display_prev_controlled() -> void:
	if SB.prev_controlled:
		display_prev_controlled.set_text(default_color + "Last controlling: %s" % SB.prev_controlled.name)
	else:
		display_prev_controlled.set_text(default_color + "Last controlling: ??")

func set_display_chunk_coords() -> void:
	if SB.controlled or SB.camera:
		var e: Node3D = null
		if SB.controlled:
			e = SB.controlled
		elif SB.camera:
			e = SB.camera
		var coords_x = floor(e.global_position.x / SB.chunk_size)
		var coords_z = floor(e.global_position.z / SB.chunk_size)
		display_chunk_coords.set_text(x_color + "%s, " % coords_x + z_color + "%s" % coords_z)
	else:
		display_chunk_coords.set_text(x_color + "?, " + z_color + "?")

func set_display_coordinates() -> void:
	if SB.controlled or SB.camera:
		var coords: Vector3 = Vector3.ZERO
		var e: Node3D = null
		if SB.controlled:
			e = SB.controlled
		elif SB.camera:
			e = SB.camera
		coords = e.get_coords()
		display_coordinate.set_text(x_color + "X: %s\n" % coords[0] + y_color + "Y: %s\n" % coords[1] + z_color + "Z: %s" % coords[2])
	else:
		display_coordinate.set_text(x_color + "X: ?\n" + y_color + "Y: ?\n" + z_color + "Z: ?")

func set_command_console(toggle: bool) -> void:
	if toggle:
		SB.interface.debug_open = true
		command_console.visible = true
		command_console.command_input.grab_focus()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		if command_console.command_display.text == "":
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

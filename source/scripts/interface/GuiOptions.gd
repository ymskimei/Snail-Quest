extends Menu

onready var tabs: TabContainer = $"%Tabs"
onready var video: TextureButton = $"%ButtonVideo"
onready var fullscreen: CheckBox = $"%CheckBoxFullscreen"
onready var filter: OptionButton = $"%ButtonFilter"
onready var resolution: OptionButton = $"%ButtonResolution"
onready var framerate: OptionButton = $"%ButtonFps"
onready var vsync: CheckBox = $"%CheckBoxVsync"
onready var language: OptionButton = $"%ButtonLanguage"

var resolution_dict: Dictionary = {
	"GUI_OPTIONS_RESOLUTION_480": Vector2(640, 480),
	"GUI_OPTIONS_RESOLUTION_600": Vector2(800, 600),
	"GUI_OPTIONS_RESOLUTION_768": Vector2(1024, 768),
	"GUI_OPTIONS_RESOLUTION_720": Vector2(1280, 720),
	"GUI_OPTIONS_RESOLUTION_1080": Vector2(1920, 1080),
	"GUI_OPTIONS_RESOLUTION_1440": Vector2(2560, 1440)
}

var filter_dict: Dictionary = {
	"GUI_OPTIONS_FILTER_CONTRASTED": 0,
	"GUI_OPTIONS_FILTER_MONOCHROME": 1,
	"GUI_OPTIONS_FILTER_PROTANOPIA": 2,
	"GUI_OPTIONS_FILTER_DEUTERANOPIA": 3,
	"GUI_OPTIONS_FILTER_TRITANOPIA": 4,
	"GUI_OPTIONS_FILTER_ACHROMATOPSIA": 5
}

var framerate_dict: Dictionary = {
	"GUI_OPTIONS_FPS_30": 30,
	"GUI_OPTIONS_FPS_60": 60,
	"GUI_OPTIONS_FPS_120": 120
}

var language_dict: Dictionary = {
	"GUI_OPTIONS_LANGUAGE_EN_US": "en_US",
	"GUI_OPTIONS_LANGUAGE_EN_GB": "en_GB",
	"GUI_OPTIONS_LANGUAGE_ES_MX": "es_MX",
	"GUI_OPTIONS_LANGUAGE_ES_AR": "es_AR",
	"GUI_OPTIONS_LANGUAGE_JA_JP": "ja_JP",
	"GUI_OPTIONS_LANGUAGE_PR": "pr"
}

const button_a: String = "res://assets/texture/interface/button_a.png"
const button_b: String = "res://assets/texture/interface/button_b.png"
const button_x: String = "res://assets/texture/interface/button_x.png"
const button_y: String = "res://assets/texture/interface/button_y.png"
const button_fork: String = "res://assets/texture/interface/button_fork.png"
const button_circle: String = "res://assets/texture/interface/button_circle.png"
const button_square: String = "res://assets/texture/interface/button_square.png"
const button_triangle: String = "res://assets/texture/interface/button_triangle.png"
const button_left: String = "res://assets/texture/interface/button_left.png"
const button_left_2: String = "res://assets/texture/interface/button_left_2.png"
const button_right: String = "res://assets/texture/interface/button_right.png"
const button_right_2: String = "res://assets/texture/interface/button_right_2.png"
const button_minus: String = "res://assets/texture/interface/button_minus.png"
const button_plus: String = "res://assets/texture/interface/button_plus.png"
const button_select: String = "res://assets/texture/interface/button_select.png"
const button_start: String = "res://assets/texture/interface/button_start.png"
const button_share: String = "res://assets/texture/interface/button_share.png"
const button_options: String = "res://assets/texture/interface/button_options.png"
const button_temp: String = "res://assets/texture/interface/temp_normal.png"
const stick_left_press: String = "res://assets/texture/interface/stick_left_press.png"
const stick_right_press: String = "res://assets/texture/interface/stick_right_press.png"
const stick_left_up: String = "res://assets/texture/interface/stick_left_up.png"
const stick_left_down: String = "res://assets/texture/interface/stick_left_down.png"
const stick_left_left: String = "res://assets/texture/interface/stick_left_left.png"
const stick_left_right: String = "res://assets/texture/interface/stick_left_right.png"
const stick_right_up: String = "res://assets/texture/interface/stick_right_up.png"
const stick_right_down: String = "res://assets/texture/interface/stick_right_down.png"
const stick_right_left: String = "res://assets/texture/interface/stick_right_left.png"
const stick_right_right: String = "res://assets/texture/interface/stick_right_right.png"
const pad_up: String = "res://assets/texture/interface/pad_up.png"
const pad_down: String = "res://assets/texture/interface/pad_down.png"
const pad_left: String = "res://assets/texture/interface/pad_left.png"
const pad_right: String = "res://assets/texture/interface/pad_right.png"

var last_focus: Control
var new_focus: Control
var mono_audio: bool
var can_remap: bool
var remap_timer: Timer = Timer.new()

func _ready() -> void:
	add_resolution()
	add_framerate()
	add_language()
	remap_timer.set_wait_time(0.5)
	remap_timer.one_shot = true
	remap_timer.connect("timeout", self, "on_remap_timeout")
	default_focus = fullscreen

func _unhandled_input(event: InputEvent) -> void:
	if (event is InputEventKey or event is InputEventJoypadButton) and event.is_pressed():
		for b in tabs.get_node("Controls").get_children():
			if b is TextureButton and b.is_focused():
				print("test3")
				var current_control = b.name
				if can_remap:
					print("test")
					if event is InputEventKey:
						Utility.input.set_action_key(current_control, event.as_text())
					elif event is InputEventJoypadButton:
						Utility.input.set_action_button(current_control, event.button_index)
					b.texture_normal = get_control_icon(event)
				else:
					can_remap = true
					remap_timer.start()

func get_control_icon(event: InputEvent) -> String:
	var i = Utility.input
	match event.button_index:
		0:
			if i.device == i.DEVICE_CONTROLLER_TYPE_1:
				return button_b
			elif i.device == i.DEVICE_CONTROLLER_TYPE_2:
				return button_fork
			elif i.device == i.DEVICE_CONTROLLER_TYPE_3:
				return button_a
			elif i.device == i.DEVICE_KEYBOARD:
				return button_temp
			else:
				return button_temp
		1:
			if i.device == i.DEVICE_CONTROLLER_TYPE_1:
				return button_a
			elif i.device == i.DEVICE_CONTROLLER_TYPE_2:
				return button_circle
			elif i.device == i.DEVICE_CONTROLLER_TYPE_3:
				return button_b
			elif i.device == i.DEVICE_KEYBOARD:
				return button_temp
			else:
				return button_temp
		2:
			if i.device == i.DEVICE_CONTROLLER_TYPE_1:
				return button_y
			elif i.device == i.DEVICE_CONTROLLER_TYPE_2:
				return button_square
			elif i.device == i.DEVICE_CONTROLLER_TYPE_3:
				return button_x
			elif i.device == i.DEVICE_KEYBOARD:
				return button_temp
			else:
				return button_temp
		3:
			if i.device == i.DEVICE_CONTROLLER_TYPE_1:
				return button_x
			elif i.device == i.DEVICE_CONTROLLER_TYPE_2:
				return button_triangle
			elif i.device == i.DEVICE_CONTROLLER_TYPE_3:
				return button_y
			elif i.device == i.DEVICE_KEYBOARD:
				return button_temp
			else:
				return button_temp
		4:
			if i.device == i.DEVICE_CONTROLLER_TYPE_1:
				return button_left
			elif i.device == i.DEVICE_CONTROLLER_TYPE_2:
				return button_left
			elif i.device == i.DEVICE_CONTROLLER_TYPE_3:
				return button_left
			elif i.device == i.DEVICE_KEYBOARD:
				return button_temp
			else:
				return button_temp
		5:
			if i.device == i.DEVICE_CONTROLLER_TYPE_1:
				return button_right
			elif i.device == i.DEVICE_CONTROLLER_TYPE_2:
				return button_right
			elif i.device == i.DEVICE_CONTROLLER_TYPE_3:
				return button_right
			elif i.device == i.DEVICE_KEYBOARD:
				return button_temp
			else:
				return button_temp
		6:
			if i.device == i.DEVICE_CONTROLLER_TYPE_1:
				return button_left_2
			elif i.device == i.DEVICE_CONTROLLER_TYPE_2:
				return button_left_2
			elif i.device == i.DEVICE_CONTROLLER_TYPE_3:
				return button_left_2
			elif i.device == i.DEVICE_KEYBOARD:
				return button_temp
			else:
				return button_temp
		7:
			if i.device == i.DEVICE_CONTROLLER_TYPE_1:
				return button_right_2
			elif i.device == i.DEVICE_CONTROLLER_TYPE_2:
				return button_right_2
			elif i.device == i.DEVICE_CONTROLLER_TYPE_3:
				return button_right_2
			elif i.device == i.DEVICE_KEYBOARD:
				return button_temp
			else:
				return button_temp
		8:
			if i.device == i.DEVICE_CONTROLLER_TYPE_1:
				return stick_left_press
			elif i.device == i.DEVICE_CONTROLLER_TYPE_2:
				return stick_left_press
			elif i.device == i.DEVICE_CONTROLLER_TYPE_3:
				return stick_left_press
			elif i.device == i.DEVICE_KEYBOARD:
				return button_temp
			else:
				return button_temp
		9:
			if i.device == i.DEVICE_CONTROLLER_TYPE_1:
				return stick_right_press
			elif i.device == i.DEVICE_CONTROLLER_TYPE_2:
				return stick_right_press
			elif i.device == i.DEVICE_CONTROLLER_TYPE_3:
				return stick_right_press
			elif i.device == i.DEVICE_KEYBOARD:
				return button_temp
			else:
				return button_temp
		10:
			if i.device == i.DEVICE_CONTROLLER_TYPE_1:
				return button_minus
			elif i.device == i.DEVICE_CONTROLLER_TYPE_2:
				return button_share
			elif i.device == i.DEVICE_CONTROLLER_TYPE_3:
				return button_select
			elif i.device == i.DEVICE_KEYBOARD:
				return button_temp
			else:
				return button_temp
		11:
			if i.device == i.DEVICE_CONTROLLER_TYPE_1:
				return button_plus
			elif i.device == i.DEVICE_CONTROLLER_TYPE_2:
				return button_options
			elif i.device == i.DEVICE_CONTROLLER_TYPE_3:
				return button_start
			elif i.device == i.DEVICE_KEYBOARD:
				return button_temp
			else:
				return button_temp
		12:
			if i.device == i.DEVICE_CONTROLLER_TYPE_1:
				return pad_up
			elif i.device == i.DEVICE_CONTROLLER_TYPE_2:
				return pad_up
			elif i.device == i.DEVICE_CONTROLLER_TYPE_3:
				return pad_up
			elif i.device == i.DEVICE_KEYBOARD:
				return button_temp
			else:
				return pad_up
		_:
			return button_temp

#func _process(_delta: float):
#	for b in tabs.get_node("Controls").get_children():
#		if b is TextureButton and b.is_hovered():
#			if can_remap:
#				if Input.is_
#			else:
#				can_remap = true

func get_default_focus() -> void:
	video.grab_focus()

func get_buttons(tab: Control):
	for n in tab.get_node("Margin").get_node("Grid").get_children():
		if n is BaseButton or Range:
			print("found")
			return n

func _on_Tabs_tab_changed() -> void:
	for controls in tabs.get_children():
		if controls is BaseButton or Range:
			controls.set_focus_mode(2)
			controls.grab_focus()
			break

func _on_button_focus_entered() -> void:
	last_focus = tabs.get_focus_owner()

func _on_ButtonVideo_pressed():
	tabs.current_tab = 0

func _on_ButtonAudio_pressed():
	tabs.current_tab = 1

func _on_ButtonControls_pressed():
	tabs.current_tab = 2

func _on_ButtonMisc_pressed():
	tabs.current_tab = 3

## Video Settings
func _on_CheckBoxFullscreen_toggled(button_pressed: bool) -> void:
	get_sound_tone()
	OS.window_fullscreen = !OS.window_fullscreen

func _on_ButtonResolution_item_selected(index: int) -> void:
	get_sound_tone()
	select_resolution(index)

func _on_ButtonFilter_item_selected(index: int) -> void:
	get_sound_tone()
	select_filter(index)

func _on_ButtonFps_item_selected(index: int) -> void:
	get_sound_tone()
	var fps = framerate_dict.get(framerate.get_item_text(index))
	Engine.set_target_fps(fps)

func _on_CheckBoxVsync_toggled(button_pressed: bool) -> void:
	get_sound_tone()
	OS.vsync_enabled = !OS.vsync_enabled

## Audio Settings
func _on_BarVolumeMaster_value_changed(value: float) -> void:
	var index = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(index, linear2db(value))

func _on_BarVolumeMusic_value_changed(value: float) -> void:
	var index = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_db(index, linear2db(value))

func _on_BarVolumeSfx_value_changed(value: float) -> void:
	var index = AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_volume_db(index, linear2db(value))

func _on_CheckBoxHeadphones_toggled(button_pressed: bool) -> void:
	get_sound_tone()
	pass

func _on_CheckBoxMono_toggled(button_pressed: bool) -> void:
	get_sound_tone()
	var mode = AudioServer.get_bus_effect(AudioServer.get_bus_index("Mode"), 0)
	var mast = AudioServer.get_bus_effect(AudioServer.get_bus_index("Master"), 0)
	if !mono_audio:
		mode.pan = 1
		mast.pan = 0.5
		mono_audio = true
	else:
		mode.pan = 0
		mast.pan = 0
		mono_audio = false

## Controls Settings
func _on_CheckBoxHorizontal_toggled(button_pressed):
	if button_pressed:
		SnailQuest.control_invert_horizontal = true
	else:
		SnailQuest.control_invert_horizontal = false

func _on_CheckBoxVertical_toggled(button_pressed):
	if button_pressed:
		SnailQuest.control_invert_vertical = true
	else:
		SnailQuest.control_invert_vertical = false

func _on_BarCameraSensitivity_value_changed(value):
	pass # Replace with function body.

func _on_NinePatchRect_pressed():
	pass # Replace with function body.

## Misc Settings
func _on_ButtonLanguage_item_selected(index: int) -> void:
	get_sound_tone()
	select_language(index)

func add_resolution() -> void:
	var current_resolution = get_viewport().get_size()
	var index = 0
	for r in resolution_dict:
		resolution.add_item(r, index)
		if resolution_dict[r] == current_resolution:
			resolution._select_int(index)
		index += 1

func add_filter() -> void:
	var current_filter = SnailQuest.screen.get_type()
	var index = 0
	for r in filter_dict:
		filter.add_item(r, index)
		if filter_dict[r] == current_filter:
			filter._select_int(index)
		index += 1

func add_framerate() -> void:
	var current_fps = Engine.get_frames_per_second()
	var index = 0
	for r in framerate_dict:
		framerate.add_item(r, index)
		if framerate_dict[r] == current_fps:
			framerate._select_int(index)
		index += 1

func add_language() -> void:
	var current_lang = TranslationServer.get_locale()
	var index = 0
	for r in language_dict:
		language.add_item(r, index)
		if language_dict[r] == current_lang:
			language._select_int(index)
		index += 1

func select_resolution(index: int) -> void:
	var size = resolution_dict.get(resolution.get_item_text(index))
	OS.set_window_size(size)
	get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_VIEWPORT, SceneTree.STRETCH_ASPECT_KEEP, size)
	print("Display resolution set to: " + str(size))

func select_filter(index: int) -> void:
	var new_filter = filter_dict.get(filter.get_item_text(index))
	SnailQuest.screen.set_type(new_filter)
	print("Screen filter set to: " + new_filter)

func select_language(index: int) -> void:
	var lang = language_dict.get(language.get_item_text(index))
	TranslationServer.set_locale(lang)
	print("Language set to: " + lang)

func on_remap_timeout():
	can_remap = false

func get_sound_tone():
	SnailQuest.audio.play_sfx(SnailQuest.audio.sfx_bell_tone_next)
	

class_name Options
extends Menu

var resolution_dict: Dictionary = {
}

var filter_dict: Dictionary = {
}

var framerate_dict: Dictionary = {
	"GUI_OPTIONS_FPS_30": 30,
	"GUI_OPTIONS_FPS_60": 60,
	"GUI_OPTIONS_FPS_120": 120
}

var language_dict: Dictionary = {
	"GUI_OPTIONS_LANGUAGE_EN_US": "en_US"
}

func add_to_dict(button: OptionButton, dict: Dictionary, current: String) -> void:
	var index = 0
	for r in dict:
		button.add_item(r, index)
		if str(dict[r]) == current:
			button._select_int(index)
		index += 1

func add_resolution(button: OptionButton) -> void:
	var current_resolution = get_viewport().get_size()
	add_to_dict(button, resolution_dict, str(current_resolution))

func add_filter(button: OptionButton) -> void:
	var current_filter = SB.screen.get_type()
	add_to_dict(button, filter_dict, str(current_filter))

func add_framerate(button: OptionButton) -> void:
	var current_framerate = Engine.get_frames_per_second()
	add_to_dict(button, framerate_dict, str(current_framerate))

func add_language(button: OptionButton) -> void:
	var current_lang = TranslationServer.get_locale()
	add_to_dict(button, language_dict, str(current_lang))

func set_fullscreeen(state: bool) -> void:
	if state:
		OS.window_fullscreen = true
	else:
		OS.window_fullscreen = false

func set_resolution(button: OptionButton, i: int) -> void:
	var size = resolution_dict.get(button.get_item_text(i))
	OS.set_window_size(size)
	get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_VIEWPORT, SceneTree.STRETCH_ASPECT_KEEP, size)

func set_filter(button: OptionButton, i: int) -> void:
	var new_filter = filter_dict.get(button.get_item_text(i))
	SB.screen.set_type(new_filter)

func set_framerate(button: OptionButton, index: int) -> void:
	var fps = framerate_dict.get(button.get_item_text(index))
	Engine.set_target_fps(fps)

func set_vsync(state: bool) -> void:
	if state:
		OS.vsync_enabled = true
	else:
		OS.vsync_enabled = false

func set_volume_master(f: float) -> void:
	var index = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(index, linear2db(f))

func set_volume_music(f: float) -> void:
	var index = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_db(index, linear2db(f))

func set_volume_sfx(f: float) -> void:
	var index = AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_volume_db(index, linear2db(f))

func set_headphones_mode(state: bool) -> void:
	if state:
		pass
	else:
		pass

func set_mono_mode(state: bool) -> void:
	if state:
		pass
	else:
		pass
#	var mode = AudioServer.get_bus_effect(AudioServer.get_bus_index("Mode"), 0)
#	var mast = AudioServer.get_bus_effect(AudioServer.get_bus_index("Master"), 0)
#	if !mono_audio:
#		mode.pan = 1
#		mast.pan = 0.5
#		mono_audio = true
#	else:
#		mode.pan = 0
#		mast.pan = 0
#		mono_audio = false

func set_invert_horizontal(state: bool):
	if state:
		SB.control_invert_horizontal = true
	else:
		SB.control_invert_horizontal = false

func set_invert_vertical(state: bool):
	if state:
		SB.control_invert_vertical = true
	else:
		SB.control_invert_vertical = false

func set_camera_sensitivity(i):
	pass

func set_language(button: OptionButton, i: int) -> void:
	var lang = language_dict.get(button.get_item_text(i))
	TranslationServer.set_locale(lang)

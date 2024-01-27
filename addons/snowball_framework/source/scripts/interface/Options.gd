class_name Options
extends Menu

var debug_mode: bool = true
var invert_horizontal: bool = false
var invert_vertical: bool = false

var resolution_dict: Dictionary = {
	"OPTIONS_RESOLUTION_480": Vector2(640, 480),
	"OPTIONS_RESOLUTION_600": Vector2(800, 600),
	"OPTIONS_RESOLUTION_768": Vector2(1024, 768),
	"OPTIONS_RESOLUTION_720": Vector2(1280, 720),
	"OPTIONS_RESOLUTION_1080": Vector2(1920, 1080),
	"OPTIONS_RESOLUTION_1440": Vector2(2560, 1440)
}

var filter_dict: Dictionary = {
	"OPTIONS_FILTER_DEFAULT": 0,
	"OPTIONS_FILTER_CONTRASTED": 1,
	"OPTIONS_FILTER_MONOCHROME": 2,
	"OPTIONS_FILTER_PROTANOPIA": 3,
	"OPTIONS_FILTER_DEUTERANOPIA": 4,
	"OPTIONS_FILTER_TRITANOPIA": 5,
	"OPTIONS_FILTER_ACHROMATOPSIA": 6
}

var framerate_dict: Dictionary = {
	"OPTIONS_FPS_30": 30,
	"OPTIONS_FPS_60": 60,
	"OPTIONS_FPS_120": 120
}

var language_dict: Dictionary = {
	"OPTIONS_LANGUAGE_EN_US": "en_US",
	"OPTIONS_LANGUAGE_EN_GB": "en_GB",
	"OPTIONS_LANGUAGE_ES_MX": "es_MX",
	"OPTIONS_LANGUAGE_ES_AR": "es_AR",
	"OPTIONS_LANGUAGE_JA_JP": "ja_JP",
	"OPTIONS_LANGUAGE_PR": "pr"
}

func _ready() -> void:
	_set_from_config()

func add_to_dict(button: OptionButton, dict: Dictionary, current: String) -> void:
	var index = 0
	for r in dict:
		button.add_item(r, index)
		if str(dict[r]) == current:
			button._select_int(index)
		index += 1
		print(button.get_meta_list())

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

func _set_from_config() -> void:
	set_fullscreen(get_fullscreen())
	set_resolution(get_resolution())
	set_filter(get_filter())
	set_framerate(get_framerate())
	set_vsync(get_vsync())
	set_volume_master(get_volume_master())
	set_volume_music(get_volume_music())
	set_volume_sfx(get_volume_sfx())
	set_headphones_mode(get_headphones_mode())
	set_mono_mode(get_mono_mode())
	set_invert_horizontal(get_invert_horizontal())
	set_invert_vertical(get_invert_vertical())
	set_camera_sensitivity(get_camera_sensitivity())
	set_language(get_language())

func set_fullscreen(state: bool) -> void:
	if state:
		OS.window_fullscreen = true
	else:
		OS.window_fullscreen = false
	Data.set_config("video", "screen/fullscreen", state)

func get_fullscreen() -> bool:
	var value = Data.get_config("video", "screen/fullscreen", false)
	return value

func set_resolution(key: String) -> void:
	OS.set_window_size(resolution_dict.get(key))
	get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_VIEWPORT, SceneTree.STRETCH_ASPECT_KEEP, resolution_dict.get(key))
	Data.set_config("video", "screen/resolution", key)

func get_resolution() -> String:
	var value = Data.get_config("video", "screen/resolution", "OPTIONS_RESOLUTION_1080")
	return value

func set_filter(key: String) -> void:
	#SB.screen.set_type(i)
	#filter_dict.get(filter.get_item_text(index))
	Data.set_config("video", "screen/filter", key)

func get_filter() -> String:
	var value = Data.get_config("video", "screen/filter", "OPTIONS_FILTER_DEFAULT")
	return value

func set_framerate(key: String) -> void:
	Engine.set_target_fps(framerate_dict.get(key))
	Data.set_config("video", "screen/framerate", key)

func get_framerate() -> String:
	var value = Data.get_config("video", "screen/framerate", "OPTIONS_FPS_60")
	return value

func set_vsync(state: bool) -> void:
	if state:
		OS.vsync_enabled = true
	else:
		OS.vsync_enabled = false
	Data.set_config("video", "screen/vsync", state)

func get_vsync() -> bool:
	var value = Data.get_config("video", "screen/vsync", false)
	return value

func set_volume_master(f: float) -> void:
	var index = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(index, linear2db(f))
	Data.set_config("audio", "volume/master", f)

func get_volume_master() -> float:
	var value = Data.get_config("audio", "volume/master", 1.0)
	return value

func set_volume_music(f: float) -> void:
	var index = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_db(index, linear2db(f))
	Data.set_config("audio", "volume/music", f)

func get_volume_music() -> float:
	var value = Data.get_config("audio", "volume/music", 1.0)
	return value

func set_volume_sfx(f: float) -> void:
	var index = AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_volume_db(index, linear2db(f))
	Data.set_config("audio", "volume/sfx", f)

func get_volume_sfx() -> float:
	var value = Data.get_config("audio", "volume/sfx", 1.0)
	return value

func set_headphones_mode(state: bool) -> void:
	if state:
		pass
	else:
		pass
	Data.set_config("audio", "mode/headphones", state)

func get_headphones_mode() -> bool:
	var value = Data.get_config("audio", "mode/headphones", false)
	return value

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
	Data.set_config("audio", "mode/mono", state)

func get_mono_mode() -> bool:
	var value = Data.get_config("audio", "mode/mono", false)
	return value

func set_invert_horizontal(state: bool):
	if state:
		invert_horizontal = true
	else:
		invert_horizontal = false
	Data.set_config("controls", "camera/invert_horizontal", state)

func get_invert_horizontal() -> bool:
	var value = Data.get_config("controls", "camera/invert_horizontal", false)
	return value

func set_invert_vertical(state: bool):
	if state:
		invert_vertical = true
	else:
		invert_vertical = false
	Data.set_config("controls", "camera/invert_vertical", state)

func get_invert_vertical() -> bool:
	var value = Data.get_config("controls", "camera/invert_vertical", false)
	return value

func set_camera_sensitivity(i: int):
	Data.set_config("controls", "camera/sensitivity", i)

func get_camera_sensitivity() -> float:
	var value = Data.get_config("controls", "camera/sensitivity", 1.0)
	return value

func set_language(key: String) -> void:
	TranslationServer.set_locale(language_dict.get(key))

func get_language() -> String:
	var value = Data.get_config("misc", "language", "OPTIONS_LANGUAGE_EN_US")
	return value

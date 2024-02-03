class_name Options
extends Menu

var debug_mode: bool = true
var invert_horizontal: bool = false
var invert_vertical: bool = false

var resolutions: Array = [
	Vector2(640, 480),
	Vector2(800, 600),
	Vector2(1024, 768),
	Vector2(1280, 720),
	Vector2(1920, 1080),
	Vector2(2560, 1440)
]

var filters: Array = [
	"OPTIONS_FILTER_DEFAULT",
	"OPTIONS_FILTER_CONTRASTED",
	"OPTIONS_FILTER_MONOCHROME",
	"OPTIONS_FILTER_PROTANOPIA",
	"OPTIONS_FILTER_DEUTERANOPIA",
	"OPTIONS_FILTER_TRITANOPIA",
	"OPTIONS_FILTER_ACHROMATOPSIA"
]

var framerates: Array = [
	30,
	60,
	120,
	144
]

var languages: Array = [
	"en_US",
	"en_GB",
	"es_MX",
	"es_AR",
	"ja_JP",
	"pr"
]

func add_resolutions(button: OptionButton) -> void:
	var current_resolution = get_viewport().get_size()
	var index = 0
	for r in resolutions:
		var n = str(r).replace(", ", "x")
		button.add_item(n, index)
		if str(r) == str(current_resolution):
			button._select_int(index)
		index += 1

func add_filters(button: OptionButton) -> void:
	var current_filter = filters[0]
	var index = 0
	for r in filters:
		button.add_item(r, index)
		if str(r) == current_filter:
			button._select_int(index)
		index += 1

func add_framerates(button: OptionButton) -> void:
	var current_framerate = Engine.get_frames_per_second()
	var index = 0
	for r in framerates:
		var n = str(r) + " FPS"
		button.add_item(n, index)
		if str(r) == str(current_framerate):
			button._select_int(index)
		index += 1

func add_languages(button: OptionButton) -> void:
	var current_lang = TranslationServer.get_locale()
	var index = 0
	for r in languages:
		button.add_item(r, index)
		if str(r) == current_lang:
			button._select_int(index)
		index += 1

func set_fullscreen(state: bool) -> void:
	if state:
		OS.window_fullscreen = true
	else:
		OS.window_fullscreen = false
	Data.set_config("video", "screen/fullscreen", state)

func get_fullscreen() -> bool:
	var value = Data.get_config("video", "screen/fullscreen", false)
	return value

func set_resolution(vec2: Vector2) -> void:
	OS.set_window_size(vec2)
	get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_2D, SceneTree.STRETCH_ASPECT_EXPAND, vec2)
	Data.set_config("video", "screen/resolution", vec2)

func get_resolution() -> Vector2:
	var value = Data.get_config("video", "screen/resolution", OS.get_screen_size())
	return value

func set_filter(i: int) -> void:
	#SB.screen.set_type(i)
	#filter_dict.get(filter.get_item_text(index))
	Data.set_config("video", "screen/filter", filters.find(i))

func get_filter() -> int:
	var value = Data.get_config("video", "screen/filter", 0)
	return value

func set_framerate(i: int) -> void:
	Engine.set_target_fps(i)
	Data.set_config("video", "screen/framerate", i)

func get_framerate() -> int:
	var value = Data.get_config("video", "screen/framerate", 60)
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

func set_camera_sensitivity(i: float):
	Data.set_config("controls", "camera/sensitivity", i)

func get_camera_sensitivity() -> float:
	var value = Data.get_config("controls", "camera/sensitivity", 1.0)
	return value

func set_language(lang: String, button: OptionButton = null) -> void:
	TranslationServer.set_locale(lang)
	if button:
		for i in button.get_item_count():
			button.set_item_text(i, "OPTIONS_LANGUAGE_" + str(languages[i]).to_upper())
			#replace this with translated local name for 4.0
			#button.set_item_text(i, TranslationServer.get_locale_name(languages[i]))
	Data.set_config("misc", "language", lang)

func get_language() -> String:
	var value = Data.get_config("misc", "language", OS.get_locale())
	return value

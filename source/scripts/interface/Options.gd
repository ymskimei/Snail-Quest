class_name Options
extends Menu

onready var tabs: TabContainer = $"%Tabs"
onready var video: TextureButton = $"%ButtonVideo"

onready var fullscreen: CheckBox = $"%CheckBoxFullscreen"
onready var resolution: OptionButton = $"%ButtonResolution"
onready var filter: OptionButton = $"%ButtonFilter"
onready var framerate: OptionButton = $"%ButtonFps"
onready var vsync: CheckBox = $"%CheckBoxVsync"

onready var volume_master: HSlider = $"%BarVolumeMaster"
onready var volume_music: HSlider = $"%BarVolumeMusic"
onready var volume_sfx: HSlider = $"%BarVolumeSfx"
onready var headphones: CheckBox = $"%CheckBoxHeadphones"
onready var mono: CheckBox = $"%CheckBoxMono"

onready var camera_invert_horizontal: CheckBox = $"%CheckBoxHorizontal"
onready var camera_invert_vertical: CheckBox = $"%CheckBoxVertical"
onready var camera_sensitivity: HSlider = $"%BarCameraSensitivity"

onready var language: OptionButton = $"%ButtonLanguage"

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

var last_focus: Control
var new_focus: Control
var mono_audio: bool
var can_remap: bool
var remap_timer: Timer = Timer.new()

func _ready() -> void:
	add_resolutions(resolution)
	add_framerates(framerate)
	add_filters(filter)
	add_languages(language)
	_set_from_config()
	default_focus = fullscreen

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

func _set_from_config() -> void:
	set_fullscreen(get_fullscreen())
	#set_resolution(get_resolution())
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
	set_language(get_language(), language)
	fullscreen.set_pressed(get_fullscreen())
	resolution.select(resolutions.find(get_resolution()))
	filter.select(filters.find(get_filter()))
	framerate.select(framerates.find(get_framerate()))
	vsync.set_pressed(get_vsync())
	volume_master.set_value(get_volume_master()) 
	volume_music.set_value(get_volume_music()) 
	volume_sfx.set_value(get_volume_sfx()) 
	headphones.set_pressed(get_headphones_mode())
	mono.set_pressed(get_mono_mode())
	camera_invert_horizontal.set_pressed(get_invert_horizontal())
	camera_invert_vertical.set_pressed(get_invert_horizontal())
	camera_sensitivity.set_value(get_camera_sensitivity()) 
	language.select(languages.find(get_language()))

func set_fullscreen(state: bool) -> void:
	if state:
		OS.window_fullscreen = true
	else:
		OS.window_fullscreen = false
	Auto.data.set_config("video", "screen/fullscreen", state)

func get_fullscreen() -> bool:
	var value = Auto.data.get_config("video", "screen/fullscreen", false)
	return value

func set_resolution(vec2: Vector2) -> void:
	OS.set_window_size(vec2)
	get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_2D, SceneTree.STRETCH_ASPECT_EXPAND, vec2)
	Auto.data.set_config("video", "screen/resolution", vec2)

func get_resolution() -> Vector2:
	var value = Auto.data.get_config("video", "screen/resolution", OS.get_screen_size())
	return value

func set_filter(i: int) -> void:
	#Auto.screen.set_type(i)
	#filter_dict.get(filter.get_item_text(index))
	Auto.data.set_config("video", "screen/filter", filters.find(i))

func get_filter() -> int:
	var value = Auto.data.get_config("video", "screen/filter", 0)
	return value

func set_framerate(i: int) -> void:
	Engine.set_target_fps(i)
	Auto.data.set_config("video", "screen/framerate", i)

func get_framerate() -> int:
	var value = Auto.data.get_config("video", "screen/framerate", 60)
	return value

func set_vsync(state: bool) -> void:
	if state:
		OS.vsync_enabled = true
	else:
		OS.vsync_enabled = false
	Auto.data.set_config("video", "screen/vsync", state)

func get_vsync() -> bool:
	var value = Auto.data.get_config("video", "screen/vsync", false)
	return value

func set_volume_master(f: float) -> void:
	var index = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(index, linear2db(f))
	Auto.data.set_config("audio", "volume/master", f)

func get_volume_master() -> float:
	var value = Auto.data.get_config("audio", "volume/master", 1.0)
	return value

func set_volume_music(f: float) -> void:
	var index = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_db(index, linear2db(f))
	Auto.data.set_config("audio", "volume/music", f)

func get_volume_music() -> float:
	var value = Auto.data.get_config("audio", "volume/music", 1.0)
	return value

func set_volume_sfx(f: float) -> void:
	var index = AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_volume_db(index, linear2db(f))
	Auto.data.set_config("audio", "volume/sfx", f)

func get_volume_sfx() -> float:
	var value = Auto.data.get_config("audio", "volume/sfx", 1.0)
	return value

func set_headphones_mode(state: bool) -> void:
	if state:
		pass
	else:
		pass
	Auto.data.set_config("audio", "mode/headphones", state)

func get_headphones_mode() -> bool:
	var value = Auto.data.get_config("audio", "mode/headphones", false)
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
	Auto.data.set_config("audio", "mode/mono", state)

func get_mono_mode() -> bool:
	var value = Auto.data.get_config("audio", "mode/mono", false)
	return value

func set_invert_horizontal(state: bool):
	if state:
		invert_horizontal = true
	else:
		invert_horizontal = false
	Auto.data.set_config("controls", "camera/invert_horizontal", state)

func get_invert_horizontal() -> bool:
	var value = Auto.data.get_config("controls", "camera/invert_horizontal", false)
	return value

func set_invert_vertical(state: bool):
	if state:
		invert_vertical = true
	else:
		invert_vertical = false
	Auto.data.set_config("controls", "camera/invert_vertical", state)

func get_invert_vertical() -> bool:
	var value = Auto.data.get_config("controls", "camera/invert_vertical", false)
	return value

func set_camera_sensitivity(i: float):
	Auto.data.set_config("controls", "camera/sensitivity", i)

func get_camera_sensitivity() -> float:
	var value = Auto.data.get_config("controls", "camera/sensitivity", 1.0)
	return value

func set_language(lang: String, button: OptionButton = null) -> void:
	TranslationServer.set_locale(lang)
	if button:
		for i in button.get_item_count():
			button.set_item_text(i, "OPTIONS_LANGUAGE_" + str(languages[i]).to_upper())
			#replace this with translated local name for 4.0
			#button.set_item_text(i, TranslationServer.get_locale_name(languages[i]))
	Auto.data.set_config("misc", "language", lang)

func get_language() -> String:
	var value = Auto.data.get_config("misc", "language", OS.get_locale())
	return value

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
	set_fullscreen(button_pressed)
	if button_pressed:
		get_sound_success()
	else:
		get_sound_exit()

func _on_ButtonResolution_item_selected(index: int) -> void:
	set_resolution(resolutions[index])
	get_sound_success()

func _on_ButtonFilter_item_selected(index: int) -> void:
	set_filter(index)
	get_sound_success()

func _on_ButtonFps_item_selected(index: int) -> void:
	set_framerate(framerates[index])
	get_sound_success()

func _on_CheckBoxVsync_toggled(button_pressed: bool) -> void:
	set_vsync(button_pressed)
	if button_pressed:
		get_sound_success()
	else:
		get_sound_exit()

## Audio Settings
func _on_BarVolumeMaster_value_changed(value: float) -> void:
	set_volume_master(value)
	get_sound_switch()

func _on_BarVolumeMusic_value_changed(value: float) -> void:
	set_volume_music(value)
	get_sound_switch()

func _on_BarVolumeSfx_value_changed(value: float) -> void:
	set_volume_sfx(value)
	get_sound_switch()

func _on_CheckBoxHeadphones_toggled(button_pressed: bool) -> void:
	set_headphones_mode(button_pressed)
	if button_pressed:
		get_sound_success()
	else:
		get_sound_exit()

func _on_CheckBoxMono_toggled(button_pressed: bool) -> void:
	set_mono_mode(button_pressed)
	if button_pressed:
		get_sound_success()
	else:
		get_sound_exit()
	
## Controls Settings
func _on_CheckBoxHorizontal_toggled(button_pressed):
	set_invert_horizontal(button_pressed)
	if button_pressed:
		get_sound_success()
	else:
		get_sound_exit()

func _on_CheckBoxVertical_toggled(button_pressed):
	set_invert_vertical(button_pressed)
	if button_pressed:
		get_sound_success()
	else:
		get_sound_exit()

func _on_BarCameraSensitivity_value_changed(value):
	set_camera_sensitivity(value)
	get_sound_switch()

## Misc Settings
func _on_ButtonLanguage_item_selected(index: int) -> void:
	set_language(languages[index], language)
	get_sound_success()

func _notification(what):
	match what:
		NOTIFICATION_WM_FOCUS_IN:
			_set_from_config()

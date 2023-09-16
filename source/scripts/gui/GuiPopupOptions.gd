extends Popup

onready var fullscreen: CheckBox = $MarginContainer/Background/Tabs/Video/Margin/Grid/CheckBoxFullscreen
onready var filter: OptionButton = $MarginContainer/Background/Tabs/Video/Margin/Grid/ButtonFilter
onready var resolution: OptionButton = $MarginContainer/Background/Tabs/Video/Margin/Grid/ButtonResolution
onready var framerate: OptionButton = $MarginContainer/Background/Tabs/Video/Margin/Grid/ButtonFps
onready var vsync: CheckBox = $MarginContainer/Background/Tabs/Video/Margin/Grid/CheckBoxVsync
onready var language: OptionButton = $MarginContainer/Background/Tabs/Misc/Margin/Grid/ButtonLanguage

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

var last_focus: Control
var new_focus: Control
var mono_audio: bool

func _ready() -> void:
	add_resolution()
#	if GlobalManager.screen != null:
#		add_filter()
	add_framerate()
	add_language()
	#get_default_focus()

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("gui_left"):
		$Tabs.current_tab -= 1
	if Input.is_action_just_pressed("gui_right"):
		$Tabs.current_tab += 1

func get_default_focus() -> void:
	for tab in $Tabs.get_children():
		for controls in tab.get_node("Margin").get_node("Grid").get_children():
			if controls is BaseButton or Range:
				controls.connect("focus_entered", self, "_on_button_focus_entered")

func get_buttons(tab: Control):
	for n in tab.get_node("Margin").get_node("Grid").get_children():
		if n is BaseButton or Range:
			print("found")
			return n

func _on_Tabs_tab_changed() -> void:
#	if last_focus:
#		last_focus.grab_focus()
	for controls in $Tabs.get_children():
		if controls is BaseButton or Range:
			controls.set_focus_mode(2)
			controls.grab_focus()
			break

func _on_button_focus_entered() -> void:
	last_focus = $Tabs.get_focus_owner()

## Video Settings
func _on_CheckBoxFullscreen_toggled(button_pressed: bool) -> void:
	AudioPlayer.play_sfx(AudioPlayer.sfx_bell_tone_next)
	OS.window_fullscreen = !OS.window_fullscreen

func _on_ButtonResolution_item_selected(index: int) -> void:
	AudioPlayer.play_sfx(AudioPlayer.sfx_bell_tone_next)
	select_resolution(index)

func _on_ButtonFilter_item_selected(index: int) -> void:
	AudioPlayer.play_sfx(AudioPlayer.sfx_bell_tone_next)
	select_filter(index)

func _on_ButtonFps_item_selected(index: int) -> void:
	AudioPlayer.play_sfx(AudioPlayer.sfx_bell_tone_next)
	var fps = framerate_dict.get(framerate.get_item_text(index))
	Engine.set_target_fps(fps)

func _on_CheckBoxVsync_toggled(button_pressed: bool) -> void:
	AudioPlayer.play_sfx(AudioPlayer.sfx_bell_tone_next)
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
	AudioPlayer.play_sfx(AudioPlayer.sfx_bell_tone_next)
	pass

func _on_CheckBoxMono_toggled(button_pressed: bool) -> void:
	AudioPlayer.play_sfx(AudioPlayer.sfx_bell_tone_next)
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

## Misc Settings
func _on_ButtonLanguage_item_selected(index: int) -> void:
	AudioPlayer.play_sfx(AudioPlayer.sfx_bell_tone_next)
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
	var current_filter = GlobalManager.screen.get_type()
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

func select_filter(index: int) -> void:
	var filter = filter_dict.get(filter.get_item_text(index))
	GlobalManager.screen.set_type(filter)

func select_language(index: int) -> void:
	var lang = language_dict.get(language.get_item_text(index))
	TranslationServer.set_locale(lang)
	print("Language set to: " + lang)

#func _on_ButtonRight_pressed():
#	$Tabs.current_tab += 1
#	#current = clamp(current, 0, 3)
#
#func _on_ButtonLeft_pressed():
#	$Tabs.current_tab -= 1
#	#current = clamp(current, 0, 3)

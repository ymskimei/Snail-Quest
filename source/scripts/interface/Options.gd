extends Options

onready var tabs: TabContainer = $"%Tabs"

onready var video: TextureButton = $"%ButtonVideo"
onready var fullscreen: CheckBox = $"%CheckBoxFullscreen"

onready var filter: OptionButton = $"%ButtonFilter"
onready var resolution: OptionButton = $"%ButtonResolution"
onready var framerate: OptionButton = $"%ButtonFps"
onready var language: OptionButton = $"%ButtonLanguage"

var resolutions: Dictionary = {
	"OPTIONS_RESOLUTION_480": Vector2(640, 480),
	"OPTIONS_RESOLUTION_600": Vector2(800, 600),
	"OPTIONS_RESOLUTION_768": Vector2(1024, 768),
	"OPTIONS_RESOLUTION_720": Vector2(1280, 720),
	"OPTIONS_RESOLUTION_1080": Vector2(1920, 1080),
	"OPTIONS_RESOLUTION_1440": Vector2(2560, 1440)
}

var filters: Dictionary = {
	"OPTIONS_FILTER_CONTRASTED": 0,
	"OPTIONS_FILTER_MONOCHROME": 1,
	"OPTIONS_FILTER_PROTANOPIA": 2,
	"OPTIONS_FILTER_DEUTERANOPIA": 3,
	"OPTIONS_FILTER_TRITANOPIA": 4,
	"OPTIONS_FILTER_ACHROMATOPSIA": 5
}

var languages: Dictionary = {
	"OPTIONS_LANGUAGE_EN_GB": "en_GB",
	"OPTIONS_LANGUAGE_ES_MX": "es_MX",
	"OPTIONS_LANGUAGE_ES_AR": "es_AR",
	"OPTIONS_LANGUAGE_JA_JP": "ja_JP",
	"OPTIONS_LANGUAGE_PR": "pr"
}

var last_focus: Control
var new_focus: Control
var mono_audio: bool
var can_remap: bool
var remap_timer: Timer = Timer.new()

func _ready() -> void:
	resolution_dict.merge(resolutions)
	filter_dict.merge(filters)
	language_dict.merge(languages)
	add_resolution(resolution)
	add_framerate(framerate)
	add_language(language)
	default_focus = fullscreen

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
	set_fullscreeen(button_pressed)
	if button_pressed:
		get_sound_success()
	else:
		get_sound_exit()

func _on_ButtonResolution_item_selected(index: int) -> void:
	set_resolution(resolution, index)
	get_sound_success()

func _on_ButtonFilter_item_selected(index: int) -> void:
	set_filter(filter, index)
	get_sound_success()

func _on_ButtonFps_item_selected(index: int) -> void:
	set_framerate(framerate, index)
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
	set_language(language, index)
	get_sound_success()

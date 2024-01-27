extends Options

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

var last_focus: Control
var new_focus: Control
var mono_audio: bool
var can_remap: bool
var remap_timer: Timer = Timer.new()

func _ready() -> void:
	add_resolution(resolution)
	add_framerate(framerate)
	add_language(language)
	default_focus = fullscreen
	_set_buttons_from_config()

func _set_buttons_from_config() -> void:
	fullscreen.set_toggle_mode(get_fullscreen())
	#resolution.select(resolution.get_meta(get_resolution()))
	#filter.select(filter_dict[get_resolution()])
	#framerate.select(framerate_dict[get_resolution()])
	vsync.set_toggle_mode(get_fullscreen())
	volume_master.set_value(get_volume_master()) 
	volume_music.set_value(get_volume_music()) 
	volume_sfx.set_value(get_volume_sfx()) 
	headphones.set_toggle_mode(get_headphones_mode())
	mono.set_toggle_mode(get_mono_mode())
	camera_invert_horizontal.set_toggle_mode(get_invert_horizontal())
	camera_invert_vertical.set_toggle_mode(get_invert_horizontal())
	camera_sensitivity.set_value(get_camera_sensitivity()) 
	#language.select(language_dict[get_language()])
	
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
	print("fun")
	if button_pressed:
		get_sound_success()
	else:
		get_sound_exit()

func _on_ButtonResolution_item_selected(index: int) -> void:
	set_resolution(resolution.get_item_metadata(index))
	get_sound_success()

func _on_ButtonFilter_item_selected(index: int) -> void:
	set_filter(filter.get_item_metadata(index))
	get_sound_success()

func _on_ButtonFps_item_selected(index: int) -> void:
	set_framerate(framerate_dict.get(framerate.get_item_text(index)))
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
	set_language(language.get_item_metadata(index))
	get_sound_success()

func _notification(what):
	match what:
		NOTIFICATION_WM_FOCUS_IN:
			_set_buttons_from_config()
		NOTIFICATION_WM_FOCUS_OUT:
			pass

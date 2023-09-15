extends Popup

onready var fullscreen = $Tabs/Video/Margin/Grid/CheckBoxFullscreen
onready var filter = $Tabs/Video/Margin/Grid/ButtonFilter
onready var resolution = $Tabs/Video/Margin/Grid/ButtonResolution
onready var framerate = $Tabs/Video/Margin/Grid/ButtonFramerate
onready var vsync = $Tabs/Video/Margin/Grid/CheckBoxVsync
onready var master_volume = $Tabs/Audio/Margin/Grid/BarMasterVolume
onready var music_volume = $Tabs/Audio/Margin/Grid/BarMusicVolume
onready var sfx_volume = $Tabs/Audio/Margin/Grid/BarSfxVolume

var resolution_dict: Dictionary = {
	"2560x1440 (16:9)": Vector2(2560, 1440),
	"1920x1080 (16:9)": Vector2(1920, 1080),
	"1280x720 (16:9)": Vector2(1280, 720),
	"1024x768 (4:3)": Vector2(1024, 768),
	"800x600 (4:3)": Vector2(800, 600),
	"640x480 (4:3)": Vector2(640, 480)
}

var filter_dict: Dictionary = {
	"Contrasted": 0,
	"Monochrome": 1,
	"Protanopia": 2,
	"Deuteranopia": 3,
	"Tritanopia": 4,
	"Achromatopsia": 5
}

var framerate_dict: Dictionary = {
	"30 FPS": 30,
	"60 FPS": 60,
	"120 FPS": 120
}

var last_focus
var new_focus
var mono_audio : bool

func _ready():
	add_resolution()
#	if GlobalManager.screen != null:
#		add_filter()
	add_framerate()
	#get_default_focus()

func _unhandled_input(event):
	if Input.is_action_just_pressed("gui_left"):
		$Tabs.current_tab -= 1
	if Input.is_action_just_pressed("gui_right"):
		$Tabs.current_tab += 1

func get_default_focus():
	for tab in $Tabs.get_children():
		for controls in tab.get_node("Margin").get_node("Grid").get_children():
			if controls is BaseButton or Range:
				controls.connect("focus_entered", self, "_on_button_focus_entered")

func get_buttons(tab):
	for n in tab.get_node("Margin").get_node("Grid").get_children():
		if n is BaseButton or Range:
			print("found")
			return n

func _on_Tabs_tab_changed(tab):
#	if last_focus:
#		last_focus.grab_focus()
	for controls in $Tabs.get_child(tab).get_node("Margin").get_node("Grid").get_children():
		if controls is BaseButton or Range:
			print("real")
			controls.set_focus_mode(2)
			controls.grab_focus()
			break

func _on_button_focus_entered(control):
	last_focus = $Tabs.get_focus_owner()

## Video Settings
func _on_CheckBoxFullscreen_toggled(button_pressed):
	OS.window_fullscreen = !OS.window_fullscreen

func _on_ButtonResolution_item_selected(index):
	select_resolution(index)

func _on_ButtonFilter_item_selected(index):
	select_filter(index)

func _on_ButtonFramerate_item_selected(index):
	var fps = framerate_dict.get(framerate.get_item_text(index))
	Engine.set_target_fps(fps)

func _on_CheckBoxVsync_toggled(button_pressed):
	OS.vsync_enabled = !OS.vsync_enabled

## Audio Settings
func _on_BarMasterVolume_value_changed(value):
	var index = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(index, linear2db(value))

func _on_BarMusicVolume_value_changed(value):
	var index = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_db(index, linear2db(value))

func _on_BarSfxVolume_value_changed(value):
	var index = AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_volume_db(index, linear2db(value))

func _on_CheckBoxHeadphones_toggled(button_pressed):
	pass

func _on_CheckBoxMono_toggled(button_pressed):
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

func add_resolution():
	var current_resolution = get_viewport().get_size()
	var index = 0
	for r in resolution_dict:
		resolution.add_item(r, index)
		if resolution_dict[r] == current_resolution:
			resolution._select_int(index)
		index += 1

func add_filter():
	var current_filter = GlobalManager.screen.get_type()
	var index = 0
	for r in filter_dict:
		filter.add_item(r, index)
		if filter_dict[r] == current_filter:
			filter._select_int(index)
		index += 1

func add_framerate():
	var current_fps = Engine.get_frames_per_second()
	var index = 0
	for r in framerate_dict:
		framerate.add_item(r, index)
		if framerate_dict[r] == current_fps:
			framerate._select_int(index)
		index += 1

func select_resolution(index):
	var size = resolution_dict.get(resolution.get_item_text(index))
	OS.set_window_size(size)
	get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_VIEWPORT, SceneTree.STRETCH_ASPECT_KEEP, size)

func select_filter(index):
	var size = filter_dict.get(filter.get_item_text(index))
	GlobalManager.screen.set_type(index)

#func _on_ButtonRight_pressed():
#	$Tabs.current_tab += 1
#	#current = clamp(current, 0, 3)
#
#func _on_ButtonLeft_pressed():
#	$Tabs.current_tab -= 1
#	#current = clamp(current, 0, 3)

func _on_TextureButtonAction_button_down():
	pass # Replace with function body.

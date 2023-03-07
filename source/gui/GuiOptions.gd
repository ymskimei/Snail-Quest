extends Popup

onready var display_resolution = $Tabs/Video/Margin/Grid/ButtonDisplayResolution
onready var framerate = $Tabs/Video/Margin/Grid/ButtonFramerate
onready var vertical_sync = $Tabs/Video/Margin/Grid/CheckBoxVerticalSync
onready var master_volume = $Tabs/Audio/Margin/Grid/BarMasterVolume
onready var music_volume = $Tabs/Audio/Margin/Grid/BarMusicVolume
onready var sfx_volume = $Tabs/Audio/Margin/Grid/BarSfxVolume

var display_resolution_dict: Dictionary = {
	"2560x1440 (16:9)": Vector2(2560, 1440),
	"1920x1080 (16:9)": Vector2(1920, 1080),
	"1280x720 (16:9)": Vector2(1280, 720),
	"1024x768 (4:3)": Vector2(1024, 768),
	"800x600 (4:3)": Vector2(800, 600),
	"640x480 (4:3)": Vector2(640, 480)
}

func _ready():
	add_display_resolution()

## Video Settings
func _on_ButtonDisplayResolution_item_selected(index):
	select_display_resolution(index)

#func _on_ButtonFramerate_item_selected(index):
#	pass

#func _on_CheckBoxVerticalSync_toggled(button_pressed):
#	pass

## Audio Settings
#func _on_BarMasterVolume_value_changed(value):
#	pass

#func _on_BarMusicVolume_value_changed(value):
#	pass

#func _on_BarSfxVolume_value_changed(value):
#	pass

func add_display_resolution():
	var current_resolution = get_viewport().get_size()
	var index = 0
	for resolution in display_resolution_dict:
		display_resolution.add_item(resolution, index)
		if display_resolution_dict[resolution] == current_resolution:
			display_resolution._select_int(index)
		index += 1

func select_display_resolution(index):
	var size = display_resolution_dict.get(display_resolution.get_item_text(index))
	OS.set_window_size(size)
	get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_VIEWPORT, SceneTree.STRETCH_ASPECT_KEEP, size)

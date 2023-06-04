extends Control

onready var default_selection = $ButtonContainer/StartButton
onready var screen_data = "res://assets/world/dev/test_room_0.tscn"
onready var screen_options = $GuiOptions

func _ready():
	default_selection.grab_focus()

func _on_StartButton_pressed():
	var start = get_tree().change_scene(screen_data)
	if start != 0:
		print("Entry scene is missing")

func _on_OptionsButton_pressed():
	screen_options.popup_centered()

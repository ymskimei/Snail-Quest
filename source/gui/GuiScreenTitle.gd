extends Control

onready var default_selection = $"%StartButton"
onready var screen_options = $GuiOptions

signal game_start

func _ready():
	default_selection.grab_focus()

func _on_StartButton_pressed():
	emit_signal("game_start")
	queue_free()

func _on_OptionsButton_pressed():
	screen_options.popup_centered()

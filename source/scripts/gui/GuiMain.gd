extends Node

onready var debug = $GuiDebug
onready var options = $GuiOptions

var game_paused : bool
var options_open = false
	
func _process(_delta):
	if game_paused:
		get_tree().set_deferred("paused", true)
	else:
		get_tree().set_deferred("paused", false)

func _unhandled_input(event):
	options_popup()

func options_popup():
	if Input.is_action_just_pressed("gui_options"):
		if !options_open:
			game_paused = true
			options.popup_centered()
			options_open = true
		else:
			game_paused = false
			options.hide()
			options_open = false

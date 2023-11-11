extends Node

onready var debug = $GuiDebug
onready var menu = $GuiCamera
onready var blur = $GuiBlur

var debug_open : bool
var game_paused : bool
var options_open = false
	
func _process(_delta: float):
	if game_paused:
		get_tree().set_deferred("paused", true)
	else:
		get_tree().set_deferred("paused", false)

func _input(event: InputEvent):
	if event.is_action_pressed("gui_options"):
		menu_popup()

func menu_popup():
		if !menu_open:
			game_paused = true
			menu.set_visible(true)
			blur.set_visible(true)
			menu.find_node("GuiOptions").fullscreen.grab_focus()
			menu_open = true
		else:
			game_paused = false
			menu.set_visible(false)
			blur.set_visible(false)
			menu_open = false

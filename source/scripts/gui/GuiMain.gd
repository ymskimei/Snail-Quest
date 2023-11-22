extends Node

onready var debug = $GuiDebug
onready var menu = $GuiOptions
onready var blur = $GuiBlur
onready var cursor = $GuiCursor

var game_paused: bool
var menu_open: bool = false
	
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
			menu.set_visible(true)
			blur.set_visible(true)
			cursor.set_visible(true)
			menu.get_default_focus()
			menu_open = true
		else:
			menu.set_visible(false)
			blur.set_visible(false)
			cursor.set_visible(false)
			menu_open = false

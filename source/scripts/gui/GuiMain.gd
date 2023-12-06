extends Node

onready var debug: CanvasLayer = $GuiDebug
onready var menu: CanvasLayer = $GuiOptions
onready var cursor: CanvasLayer = $GuiCursor
onready var hud: CanvasLayer = $GuiHud
onready var blur_anim: AnimationPlayer = $GuiBlur/AnimationPlayer

var game_paused: bool = false
var menu_open: bool = false
var debug_open: bool = false

var game_focused: bool = true
var current_focused: Control

func _ready() -> void:
	get_viewport().connect("gui_focus_changed", self, "_on_gui_focus_changed")

func _on_gui_focus_changed(node: Node):
	current_focused = node

func _process(_delta: float):
	if game_paused:
		get_tree().set_deferred("paused", true)
	else:
		get_tree().set_deferred("paused", false)
	if menu_open:
		cursor.set_visible(true)
		hud.set_visible(false)
	else:
		cursor.set_visible(false)
		hud.set_visible(true)

func _input(event: InputEvent):
	if event.is_action_pressed("gui_options"):
		menu_popup()

func menu_popup():
		if !menu_open:
			menu.anim.play("Appear")
			blur_anim.play("Blur")
			menu.get_default_focus()
			menu_open = true
		else:
			menu.anim.play_backwards("Appear")
			blur_anim.play_backwards("Blur")
			menu_open = false

func _notification(what):
	match what:
		NOTIFICATION_WM_FOCUS_IN:
			game_focused = true
			if is_instance_valid(current_focused):
				current_focused.grab_focus()
		NOTIFICATION_WM_FOCUS_OUT:
			game_focused = false

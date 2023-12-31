extends Node

onready var debug: Menu = $Debug
onready var options: Menu = $Options
onready var inventory: Menu = $Inventory
onready var cursor: CanvasLayer = $Cursor
onready var hud: CanvasLayer = $HUD
onready var blur: AnimationPlayer = $Blur/AnimationPlayer

var game_focused: bool = true
var current_focus: Control
var previous_focus: Array = []
var previous_menu: Array = []

func _ready() -> void:
	get_viewport().connect("gui_focus_changed", self, "_on_gui_focus_changed")

func _process(_delta: float):
	if SnailQuest.controllable == null or get_tree().paused == true:
		hud.hide()
		cursor.show()
	elif SnailQuest.controllable is Entity or VehicleBody:
		hud.show()
		cursor.hide()

func _unhandled_input(event: InputEvent):
	if debug.visible:
		if event.is_action_pressed("gui_debug"):
			get_menu()
	else:
		if event.is_action_pressed("gui_debug"):
			get_menu(debug)
		if SnailQuest.controllable:
			if event.is_action_pressed("gui_pause"):
				get_menu(options)
			if event.is_action_pressed("gui_items"):
				get_menu(inventory)
		if event.is_action_pressed("action_combat"):
			get_menu()

func get_menu(new_menu: CanvasLayer = null) -> void:
	if new_menu and !new_menu.visible:
		previous_menu.push_front(new_menu)
		previous_focus.push_front(current_focus)
		new_menu.open(true)
		blur.play("Blur")
		pause(true)
	elif previous_menu.size() > 0:
		previous_menu.pop_front().open()
		if previous_focus.size() > 0 and is_instance_valid(previous_focus[0]):
			previous_focus.pop_front().grab_focus()
#		for m in previous_menu:
#			if m.visible == true:
#				break
#			else:
		blur.play_backwards("Blur")
		pause(false)

func pause(toggle: bool) -> void:
	if toggle:
		get_tree().set_deferred("paused", true)
	else:
		get_tree().set_deferred("paused", false)

func _on_gui_focus_changed(node: Node):
	current_focus = node

func _notification(what):
	match what:
		NOTIFICATION_WM_FOCUS_IN:
			game_focused = true
			if is_instance_valid(current_focus):
				current_focus.grab_focus()
		NOTIFICATION_WM_FOCUS_OUT:
			game_focused = false

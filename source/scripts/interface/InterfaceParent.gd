class_name InterfaceParent
extends Node

var game_focused: bool = true
var current_focus: Control = null
var previous_focus: Array = []
var previous_menu: Array = []

func _ready() -> void:
	get_viewport().connect("gui_focus_changed", self, "_on_gui_focus_changed")

func get_menu(effect: AnimationPlayer = null, new_menu: CanvasLayer = null) -> void:
	if new_menu and !new_menu.visible:
		previous_menu.push_front(new_menu)
		previous_focus.push_front(current_focus)
		new_menu.open(true)
		if effect:
			effect.play("Effect")
		Auto.utility.pause(true)
	elif previous_menu.size() > 0:
		previous_menu.pop_front().open()
		if previous_focus.size() > 0 and is_instance_valid(previous_focus[0]):
			previous_focus.pop_front().grab_focus()
		if effect:
			effect.play_backwards("Effect")
		Auto.utility.pause(false)

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

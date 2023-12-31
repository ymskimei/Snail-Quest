class_name Menu
extends CanvasLayer

onready var anim: AnimationPlayer

var default_focus: Control
var recent_focus: Control

func _ready() -> void:
	get_viewport().connect("gui_focus_changed", self, "_on_gui_focus_changed")
	if is_instance_valid($AnimationPlayer):
		anim = $AnimationPlayer

func open(toggle: bool = false) -> void:
	if toggle:
		show()
		if is_instance_valid(anim):
			anim.play("Appear")
		if is_instance_valid(recent_focus):
			recent_focus.grab_focus()
		if is_instance_valid(default_focus):
			default_focus.grab_focus()
	else:
		if anim:
			anim.play("Disappear")
			yield(anim, "animation_finished")
		hide()

func _on_gui_focus_changed(node: Node):
	recent_focus = node

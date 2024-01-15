class_name MenuParent
extends CanvasLayer

onready var anim: AnimationPlayer

var default_focus: Control
var recent_focus: Control

func _ready() -> void:
	get_viewport().connect("gui_focus_changed", self, "_on_gui_focus_changed")

func open(toggle: bool = false) -> void:
	if toggle:
		if is_instance_valid(anim):
			anim.play("Appear")
		show()
		if is_instance_valid(recent_focus):
			recent_focus.grab_focus()
		if is_instance_valid(default_focus):
			default_focus.grab_focus()
		get_sound_next()
	else:
		get_sound_exit()
		if anim:
			anim.play("Disappear")
			yield(anim, "animation_finished")
		hide()

func _on_gui_focus_changed(node: Node):
	if is_instance_valid(anim):
		if !anim.is_playing() and node.visible:
			get_sound_switch()

func get_sound_switch():
	pass

func get_sound_success():
	pass

func get_sound_next():
	pass
	
func get_sound_exit():
	pass

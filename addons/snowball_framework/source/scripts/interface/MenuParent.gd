class_name MenuParent
extends CanvasLayer

onready var anim: AnimationPlayer = null

var default_focus: Control = null
var recent_focus: Control = null

func _ready() -> void:
	get_viewport().connect("gui_focus_changed", self, "_on_gui_focus_changed")

func open(toggle: bool = false) -> void:
	if toggle:
		if anim:
			anim.play("Appear")
		show()
		if recent_focus:
			recent_focus.grab_focus()
		if default_focus:
			default_focus.grab_focus()
		get_sound_next()
	else:
		get_sound_exit()
		if anim:
			anim.play("Disappear")
			yield(anim, "animation_finished")
		hide()

func _on_gui_focus_changed(node: Node):
	if anim:
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

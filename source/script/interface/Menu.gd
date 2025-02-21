class_name Menu
extends CanvasLayer

onready var anim: AnimationPlayer = null

var default_focus: Control = null
var recent_focus: Control = null

func _ready() -> void:
	get_viewport().connect("gui_focus_changed", self, "_on_gui_focus_changed")
	if $AnimationPlayer != null:
		anim = $AnimationPlayer

func open(toggle: bool = false) -> void:
	if toggle:
		if anim:
			anim.play("Appear")
		get_sound_next()
		show()
		if recent_focus:
			recent_focus.grab_focus()
		if default_focus:
			default_focus.grab_focus()
	else:
		if anim:
			anim.play("Disappear")
			yield(anim, "animation_finished")
		get_sound_exit()
		hide()

func _on_gui_focus_changed(node: Node):
	if anim:
		if !anim.is_playing() and node.visible:
			get_sound_switch()

func get_sound_switch():
	Audio.play_sfx(RegistryAudio.tone_switch)

func get_sound_success():
	Audio.play_sfx(RegistryAudio.tone_success)

func get_sound_next():
	Audio.play_sfx(RegistryAudio.tone_next)
	
func get_sound_exit():
	Audio.play_sfx(RegistryAudio.tone_exit)

func get_sound_error():
	Audio.play_sfx(RegistryAudio.tone_error)

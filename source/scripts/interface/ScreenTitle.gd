extends Control

onready var default_selection: Control = $"%StartButton"

onready var splash: RichTextLabel = $CanvasMain/MarginContainer/HBoxContainer/LabelSplash
onready var version: RichTextLabel = $CanvasMain/MarginContainer/HBoxContainer/MarginContainer/VBoxContainer/LabelVersion
onready var info: RichTextLabel = $CanvasMain/MarginContainer/HBoxContainer/MarginContainer/VBoxContainer/LabelInfo

signal goto_data

func _ready() -> void:
	_set_title_strings()
	default_selection.grab_focus()

func _set_title_strings() -> void:
	version.set_bbcode("[color=#EFEFEF]" + TranslationServer.translate("TITLE") + " " + Auto.game.info["version"])
	info.set_bbcode("[right][color=#EFEFEF]© " + Auto.game.info["author"])
	var splashes: Array = [
		"TITLE_SPLASH_0",
		"TITLE_SPLASH_1",
		"TITLE_SPLASH_2",
		"TITLE_SPLASH_3",
		"TITLE_SPLASH_4",
		"TITLE_SPLASH_5",
		"TITLE_SPLASH_6",
		"TITLE_SPLASH_7",
		"TITLE_SPLASH_8",
		"TITLE_SPLASH_9"
	]
	randomize()
	splash.set_bbcode("[tornado radius=3 freq=2][color=#FFF896]" + TranslationServer.translate(splashes[randi() % splashes.size()]))

func _on_StartButton_pressed() -> void:
	Auto.audio.play_sfx(RegistryAudio.tone_success)
	var interface = Auto.game.interface
	interface.transition.play("GuiTransitionFade")
	yield(interface.transition, "animation_finished")
	emit_signal("goto_data")
	queue_free()

func _on_OptionsButton_pressed() -> void:
	var interface = Auto.game.interface
	interface.get_menu(interface.blur, interface.options)

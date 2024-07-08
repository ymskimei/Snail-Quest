extends Control

onready var default_selection: Control = $"%StartButton"

onready var splash: RichTextLabel = $CanvasMain/MarginContainer/HBoxContainer/LabelSplash
onready var version: RichTextLabel = $CanvasMain/MarginContainer/HBoxContainer/MarginContainer/VBoxContainer/LabelVersion
onready var info: RichTextLabel = $CanvasMain/MarginContainer/HBoxContainer/MarginContainer/VBoxContainer/LabelInfo

onready var main: CanvasLayer = $CanvasMain
onready var data: Popup = $CanvasData/Popup
onready var data_files: GridContainer = $CanvasData/Popup/MarginContainer/GridContainer

signal game_start

func _ready() -> void:
	_set_title_strings()
	default_selection.grab_focus()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(Auto.input.action_alt) and data.is_visible():
		data.popup()

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
	data.popup()
	data_files.get_child(0).get_child(1).grab_focus()

func _on_OptionsButton_pressed() -> void:
	var interface = Auto.game.interface
	interface.get_menu(interface.blur, interface.options)

func _on_DataFile0_button_down() -> void:
	_start_game(0)

func _on_DataFile1_button_down() -> void:
	_start_game(1)

func _on_DataFile2_button_down() -> void:
	_start_game(2)

func _on_DataFile3_button_down() -> void:
	_start_game(3)

func _start_game(file: int) -> void:
	Auto.audio.play_sfx(RegistryAudio.tone_success)
	var fade = $GuiTransition/AnimationPlayer
	fade.play("GuiTransitionFade")
	yield(fade, "animation_finished")
	emit_signal("game_start")
	queue_free()

extends Control

onready var default_selection: TextureButton = $MarginContainer/GridContainer/DataFile0

signal goto_title
signal game_start

func _ready() -> void:
	default_selection.grab_focus()

func _unhandled_input(event: InputEvent):
	if event.is_action_pressed(Auto.input.action_alt) and !Auto.input.get_block_input():
		Auto.audio.play_sfx(RegistryAudio.tone_success)
		Auto.game.change_screen(Auto.game.title)

func _on_DataFile0_button_down() -> void:
	_start_game(0)

func _on_DataFile1_button_down() -> void:
	_start_game(1)

func _on_DataFile2_button_down() -> void:
	_start_game(2)

func _on_DataFile3_button_down() -> void:
	_start_game(3)

func _start_game(folder: int) -> void:
	if !Auto.input.get_block_input():
		Auto.audio.play_sfx(RegistryAudio.tone_success)
		Auto.game.change_screen(Auto.game.world)

func _on_OptionsButton_pressed() -> void:
	if !Auto.input.get_block_input():
		var interface = Auto.game.interface
		interface.get_menu(interface.blur, interface.options)

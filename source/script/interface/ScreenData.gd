extends Control

onready var default_selection: TextureButton = $MarginContainer/GridContainer/DataFile0

func _ready() -> void:
	default_selection.grab_focus()
	Audio.music_booth.play_song("Data")

func _unhandled_input(event: InputEvent):
	if event.is_action_pressed(Device.action_alt) and !Device.get_block_input():
		Audio.play_sfx(RegistryAudio.tone_success)
		Audio.music_booth.stop_song(0.0)
		get_parent().change_screen(SnailQuest.title)

func _on_DataFile0_button_down() -> void:
	_start_game(0)

func _on_DataFile1_button_down() -> void:
	_start_game(1)

func _on_DataFile2_button_down() -> void:
	_start_game(2)

func _on_DataFile3_button_down() -> void:
	_start_game(3)

func _start_game(folder: int) -> void:
	if !Device.get_block_input():
		Data.set_current_data_folder(Data.get_data_folder(folder))
		Audio.play_sfx(RegistryAudio.tone_success)
		Audio.music_booth.stop_song(0.0)
		get_parent().change_screen(SnailQuest.world)

func _on_OptionsButton_pressed() -> void:
	if !Device.get_block_input():
		Interface.get_menu(Interface.blur, Interface.options)

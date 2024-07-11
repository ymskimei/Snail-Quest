extends Control

onready var default_selection: TextureButton = $MarginContainer/GridContainer/DataFile0

signal goto_title
signal game_start

func _ready() -> void:
	default_selection.grab_focus()
	Audio.music_booth.play_song("Data")
	
func _unhandled_input(event: InputEvent):
	if event.is_action_pressed(Device.action_alt) and !Device.get_block_input():
		Audio.play_sfx(RegistryAudio.tone_success)
		Audio.music_booth.stop_song(0.0)
		get_parent().change_screen(SnailQuest.title)

#func _process(delta: float) -> void:
#	for n in $MarginContainer/GridContainer.get_children():
#		if n == get_focus_owner() and n.is_active:
#			Audio.music_booth.play_track(1, 0.5)
#		else:
#			Audio.music_booth.stop_track(1, 0.5)

func _on_DataFile0_button_down() -> void:
	_start_game(0)

func _on_DataFile1_button_down() -> void:
	_start_game(1)

func _on_DataFile2_button_down() -> void:
	_start_game(2)

func _on_DataFile3_button_down() -> void:
	_start_game(3)

func _start_game(folder: int) -> void:
	Audio.music_booth.stop_song(0.0)
	if !Device.get_block_input():
		Audio.play_sfx(RegistryAudio.tone_success)
		get_parent().change_screen(SnailQuest.world)

func _on_OptionsButton_pressed() -> void:
	if !Device.get_block_input():
		Interface.get_menu(Interface.blur, Interface.options)

extends Control

onready var default_selection: TextureButton = $MarginContainer/GridContainer/DataFile0

signal game_start

func _ready() -> void:
	Auto.game.interface.transition.play_backwards("GuiTransitionFade")
	default_selection.grab_focus()

func _on_DataFile0_button_down() -> void:
	_start_game(0)

func _on_DataFile1_button_down() -> void:
	_start_game(1)

func _on_DataFile2_button_down() -> void:
	_start_game(2)

func _on_DataFile3_button_down() -> void:
	_start_game(3)

func _start_game(folder: int) -> void:
	Auto.data.set_current_data_folder(Auto.data.get_data_folder(folder))
	Auto.audio.play_sfx(RegistryAudio.tone_success)
	var interface = Auto.game.interface
	interface.transition.play("GuiTransitionFade")
	yield(interface.transition, "animation_finished")
	emit_signal("game_start")
	queue_free()

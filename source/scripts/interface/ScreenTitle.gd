extends Control

onready var default_selection: Control = $CanvasMain/MarginContainer/HBoxContainer/MarginContainer/VBoxContainer/ButtonContainer/StartButton

onready var splash: RichTextLabel = $CanvasMain/MarginContainer/HBoxContainer/LabelSplash
onready var version: RichTextLabel = $CanvasMain/MarginContainer/HBoxContainer/MarginContainer/VBoxContainer/LabelVersion
onready var info: RichTextLabel = $CanvasMain/MarginContainer/HBoxContainer/MarginContainer/VBoxContainer/LabelInfo

func _ready() -> void:
	_set_title_strings()
	default_selection.grab_focus()
	Audio.music_booth.play_song("Title")
	Audio.music_booth.play_track(1)
	Audio.music_booth.play_track(2)
	Audio.music_booth.play_track(3)

func _set_title_strings() -> void:
	version.set_bbcode("[color=#EFEFEF]" + TranslationServer.translate("TITLE") + " " + SnailQuest.info["version"])
	info.set_bbcode("[right][color=#EFEFEF]© " + SnailQuest.info["author"])
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
	if !Device.get_block_input():
		Audio.play_sfx(RegistryAudio.tone_success)
		Audio.music_booth.stop_song(0.0)
		get_parent().change_screen(SnailQuest.data)

func _on_LobbyButton_pressed():
	if !Device.get_block_input():
		Audio.play_sfx(RegistryAudio.tone_success)
		Audio.music_booth.stop_song(0.0)
		get_parent().change_screen(SnailQuest.lobby)

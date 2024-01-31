@tool
extends EditorPlugin

func _enter_tree() -> void:
	add_custom_type("MusicBooth", "Node", preload("source/music/MusicBooth.gd"), preload("graphics/icons/icon.png"))
	add_custom_type("Song", "Node", preload("source/music/Song.gd"), preload("graphics/icons/icon.png"))
	add_custom_type("TrackContainer", "Node", preload("source/music/containers/TrackContainer.gd"), preload("graphics/icons/icon.png"))
	add_custom_type("StingerContainer", "Node", preload("source/music/containers/StingerContainer.gd"), preload("graphics/icons/icon.png"))
	add_custom_type("SoundBooth", "Node", preload("source/sfx/SoundBooth.gd"), preload("graphics/icons/icon.png"))
	add_custom_type("Sound", "AudioStreamPlayer", preload("source/sfx/Sound.gd"), preload("graphics/icons/icon.png"))
	add_custom_type("Sound2D", "AudioStreamPlayer2D", preload("source/sfx/Sound2D.gd"), preload("graphics/icons/icon.png"))
	add_custom_type("Sound3D", "AudioStreamPlayer3D", preload("source/sfx/Sound3D.gd"), preload("graphics/icons/icon.png"))

func _exit_tree() -> void:
	remove_custom_type("MusicBooth")
	remove_custom_type("Song")
	remove_custom_type("TrackContainer")
	remove_custom_type("StingerContainer")
	remove_custom_type("SoundBooth")
	remove_custom_type("Sound")
	remove_custom_type("Sound2D")
	remove_custom_type("Sound3D")

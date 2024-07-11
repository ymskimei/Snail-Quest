extends Spatial

func _ready():
	Audio.music_booth.play_song("Chamber")
	Audio.music_booth.play_track(1)
	#Audio.music_booth.play_track(2)
	Audio.music_booth.play_track(3)

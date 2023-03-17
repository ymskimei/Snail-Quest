extends Node

func play_sfx(sound):
	var sfx = AudioStreamPlayer.new()
	sfx.stream = sound
	add_child(sfx)
	sfx.play()
	yield(sfx, "finished")
	sfx.queue_free()

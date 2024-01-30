class_name Menu
extends MenuParent

func _ready() -> void:
	if $AnimationPlayer:
		anim = $AnimationPlayer

func get_sound_switch():
	Audio.play_sfx(RegistryAudio.tone_switch)

func get_sound_success():
	Audio.play_sfx(RegistryAudio.tone_success)

func get_sound_next():
	Audio.play_sfx(RegistryAudio.tone_next)
	
func get_sound_exit():
	Audio.play_sfx(RegistryAudio.tone_exit)

func get_sound_error():
	Audio.play_sfx(RegistryAudio.tone_error)

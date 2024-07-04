class_name Menu
extends MenuParent

func _ready() -> void:
	if $AnimationPlayer:
		anim = $AnimationPlayer

func get_sound_switch():
	Auto.audio.play_sfx(RegistryAudio.tone_switch)

func get_sound_success():
	Auto.audio.play_sfx(RegistryAudio.tone_success)

func get_sound_next():
	Auto.audio.play_sfx(RegistryAudio.tone_next)
	
func get_sound_exit():
	Auto.audio.play_sfx(RegistryAudio.tone_exit)

func get_sound_error():
	Auto.audio.play_sfx(RegistryAudio.tone_error)

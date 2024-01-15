class_name Menu
extends MenuParent

func _ready() -> void:
	if is_instance_valid($AnimationPlayer):
		anim = $AnimationPlayer

func get_sound_switch():
	SB.utility.audio.play_sfx(RegistryAudio.tone_switch)

func get_sound_success():
	SB.utility.audio.play_sfx(RegistryAudio.tone_success)

func get_sound_next():
	SB.utility.audio.play_sfx(RegistryAudio.tone_next)
	
func get_sound_exit():
	SB.utility.audio.play_sfx(RegistryAudio.tone_exit)

func get_sound_error():
	SB.utility.audio.play_sfx(RegistryAudio.tone_error)

extends Interactable

func _ready():
	var switch = get_node_or_null("Switch")
	if switch != null:
		switch.connect("activated", self, "on_activated")

func on_activated(is_active):
	if is_active:
		SB.utility.audio.play_pos_sfx(RegistryAudio.door_open, global_translation)
		anim.play("Open")
	else:
		anim.play_backwards("Open")

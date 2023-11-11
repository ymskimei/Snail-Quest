extends ObjectInteractable

var is_opened: bool

func get_interaction_text() -> String:
	return "open box"

func interact() -> void: 
	if is_opened:
		anim.play("Close")
		yield(anim, "animation_finished")
		is_opened = false
	else:
		anim.play("Open")
		yield(anim, "animation_finished")
		is_opened = true
	#trigger_dialog()


extends ObjectInteractable

func get_interaction_text():
	return "read sign"

func interact():
	trigger_dialog()

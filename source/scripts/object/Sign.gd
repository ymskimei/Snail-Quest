extends Interactable

func _ready() -> void:
	character = true

func get_interaction_text():
	return "read sign"

func interact():
	trigger_dialog()

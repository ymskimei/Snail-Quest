extends Interactable

func _ready() -> void:
	character = true
	anim.play("SignIdle")

func get_interaction_text():
	return "read sign"

func interact():
	trigger_dialog()

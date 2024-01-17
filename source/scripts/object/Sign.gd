extends Interactable

func _ready() -> void:
	character = true
	anim.play("SignIdle")

func get_interaction_text():
	return "read sign"

func interact():
	camera_override()
	trigger_dialog()

func dialog_end() -> void:
	camera_override(false)

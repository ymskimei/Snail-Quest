class_name Sign
extends Conversable

onready var anim: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	character = true
	anim.play("SignIdle")

func get_interaction_text():
	return tr("INTERFACE_INTERACTION_SIGN")

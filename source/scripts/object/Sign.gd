extends Conversable

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var mesh: MeshInstance3D = $MeshInstance3D

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

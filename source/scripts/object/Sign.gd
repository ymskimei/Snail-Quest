extends Interactable

export var dialog_skin: Resource = null
export var dialog_array: Resource = null

onready var anim: AnimationPlayer = $AnimationPlayer
onready var mesh: MeshInstance = $MeshInstance

func _ready() -> void:
	character = true
	anim.play("SignIdle")

func get_interaction_text():
	return "read sign"

func interact():
	camera_override()
	Event.initiate_dialog(dialog_skin, dialog_array)

func dialog_end() -> void:
	camera_override(false)

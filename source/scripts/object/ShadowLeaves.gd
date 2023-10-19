extends MeshInstance

onready var anim = $AnimationPlayer

func _ready() -> void:
	anim.play("ObjectLeavesSway")

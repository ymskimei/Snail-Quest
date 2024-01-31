extends MeshInstance3D

@onready var anim = $AnimationPlayer

func _ready() -> void:
	anim.play("ObjectLeavesSway")

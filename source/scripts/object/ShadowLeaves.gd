extends MeshInstance

onready var anim = $AnimationPlayer

func _physics_process(delta: float) -> void:
	anim.play("ObjectLeavesSway")

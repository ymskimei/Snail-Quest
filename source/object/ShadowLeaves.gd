extends MeshInstance

onready var anim = $AnimationPlayer

func _ready():
	anim.play("ObjectLeavesSway")

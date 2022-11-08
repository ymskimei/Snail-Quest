extends Camera

var cam_target = self
onready var default_target = get_node("..")

func _ready():
	pass

func _physics_process(delta):
	apply_cam_target()

func apply_cam_target():
	if default_target != null:
		cam_target = default_target

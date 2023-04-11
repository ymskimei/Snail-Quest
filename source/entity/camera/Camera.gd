class_name MainCamera
extends SpringArm

onready var player = get_parent().get_node("Player")
onready var camera_lens = $CameraLens
onready var anim_tween = $Animation/AnimationCam
onready var anim_bars = $Animation/AnimationBars
onready var anim_wobble = $Animation/AnimationWobble
onready var states = $StateController

func _ready():
	states.ready(self)
	GlobalManager.register_camera(self)

func _physics_process(delta: float) -> void:
	states.physics_process(delta)

func _unhandled_input(event: InputEvent) -> void:
	states.unhandled_input(event)

func set_coords(position : Vector3, angle : String, flipped : bool):
	var rot = deg2rad(MathHelper.cardinal_to_degrees(angle))
	if flipped:
		if !rot == 0:
			rot /= 0.5
		else:
			rot = PI
	set_global_translation(position)
	set_global_rotation(Vector3(0, rot, 0))

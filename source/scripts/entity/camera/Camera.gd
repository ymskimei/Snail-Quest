class_name MainCamera
extends SpringArm

onready var cam_target: Spatial
onready var camera_lens: Camera = $CameraLens
onready var anim_tween: Tween = $Animation/AnimationCam
onready var anim_bars: AnimationPlayer = $Animation/AnimationBars
onready var anim_wobble: AnimationPlayer = $Animation/AnimationWobble
onready var states: Node = $StateController

var lock_target: Spatial
var lock_to_point: bool
var debug_cam: bool

signal target_updated

func _ready() -> void:
	states.ready(self)
	SnailQuest.set_camera(self)

func _unhandled_input(event: InputEvent) -> void:
	states.unhandled_input(event)

func _physics_process(delta: float) -> void:
	states.physics_process(delta)
	find_camera_lock_points()
	update_target()

func update_target() -> void:
	if is_instance_valid(SnailQuest.controllable):
		cam_target = SnailQuest.controllable
	else:
		cam_target = null

func target_updated() -> void:
	emit_signal("target_updated", cam_target)

func find_camera_lock_points() -> void:
	if is_instance_valid(lock_target):
		if "current_camera_target" in lock_target:
			if lock_target.current_camera_target:
				lock_to_point = true
			else:
				lock_to_point = false
		else:
			var lock_distance = lock_target.get_global_translation().distance_to(cam_target.get_global_translation())
			var max_lock_distance = 17
			if lock_distance < max_lock_distance:
				lock_to_point = true
			else:
				lock_to_point = false
	else:
		lock_to_point = false
		lock_target = Utility.math.find_target(self, "lock_target")

func set_coords(position: Vector3, angle: String, flipped: bool) -> void:
	var rot = deg2rad(Utility.math.cardinal_to_degrees(angle))
	if flipped:
		if !rot == 0:
			rot /= 0.5
		else:
			rot = PI
	set_global_translation(position)
	set_global_rotation(Vector3(0, rot, 0))

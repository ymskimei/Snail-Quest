class_name MainCamera
extends SpringArm

onready var cam_target: Spatial = get_parent().get_node_or_null("Player")
onready var camera_lens: Camera = $CameraLens
onready var anim_tween: Tween = $Animation/AnimationCam
onready var anim_bars: AnimationPlayer = $Animation/AnimationBars
onready var anim_wobble: AnimationPlayer = $Animation/AnimationWobble
onready var states: Node = $StateController

var lock_target: Spatial
var lock_to_point: bool
var debug_cam: bool
var targeting_vehicle: bool

signal target_updated

func _ready() -> void:
	states.ready(self)
	GlobalManager.register_camera(self)

func _unhandled_input(event: InputEvent) -> void:
	states.unhandled_input(event)

func _physics_process(delta: float) -> void:
	states.physics_process(delta)
	find_camera_lock_points()

func update_target() -> void:
	if is_instance_valid(GlobalManager.vehicle):
		targeting_vehicle = true
		cam_target = GlobalManager.vehicle
	else:
		targeting_vehicle = false
		for p in get_parent().get_children():
			if p is Entity:
				if p.controllable:
					cam_target = p

func target_updated() -> void:
	emit_signal("target_updated", cam_target)

func find_camera_lock_points() -> void:
	if is_instance_valid(lock_target):
		var lock_distance = lock_target.get_global_translation().distance_to(cam_target.get_global_translation())
		var max_lock_distance = 17
		if lock_distance < max_lock_distance:
			lock_to_point = true
		else:
			lock_to_point = false
	else:
		lock_to_point = false
		lock_target = MathHelper.find_target(self, "camera")

func set_coords(position: Vector3, angle: String, flipped: bool) -> void:
	var rot = deg2rad(MathHelper.cardinal_to_degrees(angle))
	if flipped:
		if !rot == 0:
			rot /= 0.5
		else:
			rot = PI
	set_global_translation(position)
	set_global_rotation(Vector3(0, rot, 0))

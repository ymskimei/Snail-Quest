class_name MainCamera
extends SpringArm

onready var lens: Camera = $CameraLens

onready var anim_tween: Tween = $Animation/AnimationCam
onready var anim_bars: AnimationPlayer = $Animation/AnimationBars
onready var anim_wobble: AnimationPlayer = $Animation/AnimationWobble
onready var states: Node = $StateController

var target: Spatial
var positioner: Position3D
var override: Position3D

var debug_cam: bool

signal target_updated

func _ready() -> void:
	states.ready(self)
	SB.set_camera(self)

func _unhandled_input(event: InputEvent) -> void:
	states.unhandled_input(event)

func _physics_process(delta: float) -> void:
	states.physics_process(delta)
	_update_positioner()
	_update_target()

func _update_target() -> void:
	if is_instance_valid(override):
		target = override
	elif is_instance_valid(positioner):
		target = positioner
	elif is_instance_valid(SB.controlled):
		if is_instance_valid(SB.controlled.target_proxy):
			target = SB.controlled.target_proxy
		else:
			target = SB.controlled
	else:
		target = null

#func target_updated() -> void:
#	emit_signal("target_updated", cam_target)

func _update_positioner() -> void:
	var p = SB.utility.find_target(self, "positioner")
	if is_instance_valid(SB.controlled) and p:
		var distance = p.get_global_translation().distance_to(SB.controlled.get_global_translation())
		var max_distance = 17
		if distance < max_distance:
			positioner = p
		else:
			positioner = null

func set_coords(position: Vector3, angle: String, flipped: bool) -> void:
	var rot = deg2rad(SB.utility.cardinal_to_degrees(angle))
	if flipped:
		if !rot == 0:
			rot /= 0.5
		else:
			rot = PI
	set_global_translation(position)
	set_global_rotation(Vector3(0, rot, 0))

class_name MainCamera
extends SpringArm

onready var lens: Camera = $CameraLens

onready var anim_tween: Tween = $Animation/AnimationCam
onready var anim_bars: AnimationPlayer = $Animation/AnimationBars
onready var anim_wobble: AnimationPlayer = $Animation/AnimationWobble
onready var states: Node = $StateController

var target: Spatial = null
var positioner: Position3D = null
var override: Position3D = null

var debug_cam: bool = false

var looking: bool = false

signal target_updated

func _ready() -> void:
	states.ready(self)
	SnailQuest.set_camera(self)

func _unhandled_input(event: InputEvent) -> void:
	states.unhandled_input(event)

func _physics_process(delta: float) -> void:
	states.physics_process(delta)
	_update_positioner()
	_update_target()

func _update_target() -> void:
	if override:
		target = override
	elif positioner:
		target = positioner
	elif SnailQuest.controlled:
		if SnailQuest.controlled.target_proxy:
			target = SnailQuest.controlled.target_proxy
		else:
			target = SnailQuest.controlled
	else:
		target = null

func _update_positioner() -> void:
	var positioners = Utility.get_group_by_nearest(self, "positioner")
	if positioners.size() > 0:
		var p = positioners[0]
		if SnailQuest.controlled and p:
			var distance = p.get_global_translation().distance_to(SnailQuest.controlled.get_global_translation())
			var max_distance = 17
			if distance < max_distance:
				positioner = p
			else:
				positioner = null

func get_coords(raw: bool = false) -> Vector3:
	var x = global_transform.origin.x
	var y = global_transform.origin.y
	var z = global_transform.origin.z
	if !raw:
		x = round(x)
		y = round(y)
		z = round(z)
	var coords = [x, y, z]
	return coords

func set_coords(position: Vector3, angle: String = "NORTH", flipped: bool = false) -> void:
	var rot = deg2rad(Utility.cardinal_to_degrees(angle))
	if flipped:
		if !rot == 0:
			rot /= 0.5
		else:
			rot = PI
	set_global_translation(position)
	set_global_rotation(Vector3(0, rot, 0))

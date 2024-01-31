class_name MainCamera
extends Interactable

@onready var lens: Camera3D = $CameraLens
@onready var collision: CollisionShape3D = $CollisionShape3D

@onready var anim_tween: Tween = Tween.new()
@onready var anim_bars: AnimationPlayer = $Animation/AnimationBars
@onready var anim_wobble: AnimationPlayer = $Animation/AnimationWobble
@onready var states: Node = $StateController

var target: Node3D = null
var positioner: Marker3D = null
var override: Marker3D = null

var arm_length: int = 0

var debug_cam: bool = false

signal target_updated

func _ready() -> void:
	states.states_ready(self)
	SB.set_camera(self)

func _unhandled_input(event: InputEvent) -> void:
	states.states_unhandled_input(event)

func _physics_process(delta: float) -> void:
	states.states_physics_process(delta)
	_update_positioner()
	_update_target()
	_update_arm(delta)

func _update_arm(delta: float):
	lens.position.z = lerp(lens.position.z, float(arm_length), 20 * delta)

func _update_target() -> void:
	if override:
		target = override
	elif positioner:
		target = positioner
	elif SB.controlled:
		if SB.controlled.target_proxy:
			target = SB.controlled.target_proxy
		else:
			target = SB.controlled
	else:
		target = null

#func target_updated() -> void:
#	emit_signal("target_updated", cam_target)

func _update_positioner() -> void:
	var p = Utility.find_target(self, "positioner")
	if SB.controlled and p:
		var distance = p.get_global_position().distance_to(SB.controlled.get_global_position())
		var max_distance = 17
		if distance < max_distance:
			positioner = p
		else:
			positioner = null

func set_coords(position: Vector3, angle: String = "NORTH", flipped: bool = false) -> void:
	var rot = deg_to_rad(Utility.cardinal_to_degrees(angle))
	if flipped:
		if !rot == 0:
			rot /= 0.5
		else:
			rot = PI
	set_global_position(position)
	set_global_rotation(Vector3(0, rot, 0))

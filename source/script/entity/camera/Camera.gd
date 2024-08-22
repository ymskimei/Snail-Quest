class_name MainCamera
extends SpringArm

onready var lens: Camera = $CameraLens

onready var anim_tween: Tween = $Animation/AnimationCam
onready var anim_bars: AnimationPlayer = $Animation/AnimationBars
onready var anim_wobble: AnimationPlayer = $Animation/AnimationWobble
onready var states: Node = $StateController

onready var overlay_water: CanvasLayer = $OverlayWater

var target: Spatial = null
var positioner: Position3D = null
var override: Position3D = null

var debug_cam: bool = false

var looking: bool = false

signal target_updated

func _ready() -> void:
	states.ready(self)
	overlay_water.set_visible(false)
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
	elif is_instance_valid(SnailQuest.get_controlled()):
		if "target_proxy" in SnailQuest.get_controlled() and SnailQuest.get_controlled().target_proxy:
			target = SnailQuest.get_controlled().target_proxy
		else:
			target = SnailQuest.get_controlled()
	else:
		target = null

func _update_positioner() -> void:
	var positioners = Utility.get_group_by_nearest(self, "positioner")
	if positioners.size() > 0:
		var p = positioners[0]
		if SnailQuest.get_controlled() and p:
			var distance = p.get_global_translation().distance_to(SnailQuest.get_controlled().get_global_translation())
			var max_distance = 17
			if distance < max_distance:
				positioner = p
			else:
				positioner = null

func get_coords(raw: bool = false) -> Vector3:
	var x = get_global_translation().x
	var y = get_global_translation().y
	var z = get_global_translation().z
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


func _on_Area_area_entered(area):
	if area.is_in_group("liquid"):
		overlay_water.set_visible(true)

func _on_Area_area_exited(area):
	if area.is_in_group("liquid"):
		overlay_water.set_visible(false)

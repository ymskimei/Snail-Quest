class_name Interactable
extends KinematicBody

onready var mesh: MeshInstance

var target_proxy: Position3D = null
var character: bool = false

signal interaction_ended

func _ready() -> void:
	target_proxy = get_node_or_null("CameraTarget")
	var visibility = VisibilityEnabler.new()
	visibility.set_enabler(VisibilityEnabler.ENABLER_FREEZE_BODIES, false)
	visibility.set_enabler(VisibilityEnabler.ENABLER_PAUSE_ANIMATIONS, true)
	add_child(visibility)

func interact():
	pass

func get_interaction_text() -> String:
	return "Interact"

func camera_override(toggle: bool = true) -> void:
	if toggle:
		if target_proxy:
			SnailQuest.get_camera().override = target_proxy
		else:
			SnailQuest.get_camera().override = self
	else:
		SnailQuest.get_camera().override = false

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

func set_coords(position: Vector3, angle: String = "NORTH") -> void:
	set_global_translation(position)
	set_global_rotation(Vector3(0, deg2rad(Utility.cardinal_to_degrees(angle)), 0))

func is_controlled() -> bool:
	if SnailQuest.controlled == self:
		return true
	return false

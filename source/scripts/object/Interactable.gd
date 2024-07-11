class_name Interactable
extends RigidBody

export var dialog: Resource = null

var target_proxy: Position3D = null
var character: bool = false

signal interaction_ended

func _ready() -> void:
	target_proxy = get_node_or_null("CameraTarget")
	_set_visibility_enabler()

func _set_visibility_enabler() -> void:
	var visibility = VisibilityEnabler.new()
	visibility.pause_animations = true
	visibility.freeze_bodies = false
	add_child(visibility)

func interact():
	pass

func get_interaction_text() -> String:
	return "Interact"

func camera_override(toggle: bool = true) -> void:
	if toggle:
		if target_proxy:
			SnailQuest.camera.override = target_proxy
		else:
			SnailQuest.camera.override = self
	else:
		SnailQuest.camera.override = false

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

func set_coords(position: Vector3, angle: String = "NORTH") -> void:
	set_global_translation(position)
	set_global_rotation(Vector3(0, deg2rad(Utility.cardinal_to_degrees(angle)), 0))

func is_controlled() -> bool:
	if SnailQuest.controlled == self:
		return true
	return false

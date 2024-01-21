class_name Interactable
extends RigidBody

export(Resource) var dialog

const fallback: DialogueResource = preload("res://addons/snowball_framework/assets/resource/error_fallback.tres")

var target_proxy: Position3D = null
var character: bool

signal interaction_ended

func _ready() -> void:
	target_proxy = get_node_or_null("CameraTarget")

func interact():
	pass

func get_interaction_text() -> String:
	return "Interact"

func camera_override(toggle: bool = true) -> void:
	if toggle:
		if target_proxy:
			SB.camera.override = target_proxy
		else:
			SB.camera.override = self
	else:
		SB.camera.override = false

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

func set_coords(position: Vector3, angle: String = "Default") -> void:
	set_global_translation(position)
	if !angle == "Default":
		set_global_rotation(Vector3(0, deg2rad(SB.utility.cardinal_to_degrees(angle)), 0))

func is_controlled() -> bool:
	if SB.controlled == self:
		return true
	return false

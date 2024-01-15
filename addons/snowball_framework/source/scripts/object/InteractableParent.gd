class_name InteractableParent
extends RigidBody

export(Resource) var dialog

const fallback: DialogueResource = preload("res://addons/snowball_framework/assets/resource/error_fallback.tres")

var character: bool

signal interaction_ended

func get_interaction_text() -> String:
	return "interact"

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
	if SB.controllable == self:
		return true
	return false

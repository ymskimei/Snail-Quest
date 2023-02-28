class_name WorldMathHelper
extends Node

static func safe_look_at(spatial : Spatial, target : Vector3) -> void:
	var origin : Vector3 = spatial.global_transform.origin
	var v_z := (origin - target).normalized()
	if origin == target:
		return
	var up := Vector3.ZERO
	for entry in [Vector3.UP, Vector3.RIGHT, Vector3.BACK]:
		var v_x : Vector3 = entry.cross(v_z).normalized()
		if v_x.length() != 0:
			up = entry
			break
	if up != Vector3.ZERO:
		spatial.look_at(target, up)

static func slerp_look_at(spatial : Spatial, target : Spatial, speed) -> void:
		var global_pos = spatial.global_transform.origin
		var target_pos = target.global_transform.origin
		var dest_transform = spatial.global_transform.looking_at(Vector3(target_pos.x, target_pos.y, target_pos.z), Vector3.UP)
		var dest_rotation = Quat(spatial.global_transform.basis).slerp(Quat(dest_transform.basis), speed)
		spatial.global_transform = Transform(Basis(dest_rotation), global_pos)

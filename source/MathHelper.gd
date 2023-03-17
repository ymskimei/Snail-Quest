extends Node

func safe_look_at(spatial : Spatial, target : Vector3) -> void:
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

func slerp_look_at(spatial : Spatial, target : Spatial, speed) -> void:
		var global_pos = spatial.global_transform.origin
		var target_pos = target.global_transform.origin
		var dest_transform = spatial.global_transform.looking_at(Vector3(target_pos.x, target_pos.y, target_pos.z), Vector3.UP)
		var dest_rotation = Quat(spatial.global_transform.basis).slerp(Quat(dest_transform.basis), speed)
		spatial.global_transform = Transform(Basis(dest_rotation), global_pos)

func find_target(node : Object, group_name : String, get_closest := true) -> Object:
	var target_group = get_tree().get_nodes_in_group("target")
	var distance_away = node.global_transform.origin.distance_to(target_group[0].global_transform.origin)
	var return_target = target_group[0]
	for index in target_group.size():
		var distance = node.global_transform.origin.distance_to(target_group[index].global_transform.origin)
		if get_closest == true and distance < distance_away:
			distance_away = distance
			return_target = target_group[index]
		elif get_closest == false and distance > distance_away:
			distance_away = distance
			return_target = target_group[index]
	return return_target

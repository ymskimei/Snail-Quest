extends Node

func rigid_look_at(state: PhysicsDirectBodyState, position: Transform, target: Vector3) -> void:
	var up_dir = Vector3(0, 1, 0)
	var cur_dir = position.basis.xform(Vector3(0, 0, 1))
	var target_dir = (target - position.origin).normalized()
	var rotation_angle = acos(cur_dir.x) - acos(target_dir.x)
	state.set_angular_velocity(up_dir * (rotation_angle / state.get_step()))

func safe_look_at(spatial: Spatial, target: Vector3) -> void:
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

func slerp_look_at(spatial: Spatial, target: Vector3, speed: float) -> void:
		var global_pos = spatial.global_transform
		var dest_transform = global_pos
		if global_pos.origin != target:
			dest_transform = global_pos.looking_at(target, Vector3.UP)
		var dest_rotation = Quat(global_pos.basis).slerp(Quat(dest_transform.basis).normalized(), speed)
		spatial.global_transform = Transform(Basis(dest_rotation), global_pos.origin)

func find_target(node: Object, group_name: String, get_closest: = true) -> Spatial:
	var target_group = get_tree().get_nodes_in_group(group_name)
	if !target_group.empty():
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
	return null

func apply_surface_align(tform: Transform, new_up: Vector3) -> Transform:
	tform.basis.y = new_up
	tform.basis.x = -tform.basis.z.cross(new_up)
	tform.basis = tform.basis.orthonormalized()
	return tform

#func degrees_to_cardinal(angle):
#	var directions = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
#	var i = int(round(angle / (360 / len(directions))))
#	return directions[i % 8]

func cardinal_to_degrees(direction: String) -> int:
	var result
	match direction:
		"NORTH":
			result = 0
		"NORTHEAST":
			result = 45
		"EAST":
			result = 90
		"SOUTHEAST":
			result = 135
		"SOUTH":
			result = 180
		"SOUTHWEST":
			result = 225
		"WEST":
			result = 270
		"NORTHWEST":
			result = 315
	return result

func get_file_paths(folder_path: String, extension: String, recursive: bool = true) -> Array:
	var dir := Directory.new()
	if dir.open(folder_path) != OK:
		printerr("Could not open directory: ", folder_path)
		return []
	if dir.list_dir_begin(true, true) != OK:
		printerr("Could not list contents of: ", folder_path)
		return []
	var file_paths := []
	var file_name := dir.get_next()
	while file_name != "":
		if dir.current_is_dir():
			if recursive:
				var dir_path = dir.get_current_dir() + "/" + file_name
				file_paths += get_file_paths(dir_path, extension, recursive)
		else:
			if file_name.get_extension() == extension:
				var file_path = dir.get_current_dir() + "/" + file_name
				file_paths.append(file_path)
		file_name = dir.get_next()
	return file_paths

func get_file_names(folder_path: String, extension: String, recursive: bool = true) -> Array:
	var dir := Directory.new()
	if dir.open(folder_path) != OK:
		printerr("Could not open directory: ", folder_path)
		return []
	if dir.list_dir_begin(true, true) != OK:
		printerr("Could not list contents of: ", folder_path)
		return []
	var file_paths := []
	var file_name := dir.get_next()
	while file_name != "":
		if dir.current_is_dir():
			if recursive:
				var dir_path = dir.get_current_dir() + "/" + file_name
				file_paths += get_file_paths(dir_path, extension, recursive)
		else:
			if file_name.get_extension() == extension:
				var file_path = dir.get_current_dir() + "/" + file_name
				file_paths.append(file_path)
		file_name = dir.get_next()
	return file_paths

extends Node

@onready var input: Node = $Input
@onready var item: Node = $Item
@onready var audio: Node = $Audio

#func get_modifications(mesh: MeshInstance) -> void:
#	pass

func rigid_look_at(state: PhysicsDirectBodyState3D, position: Transform3D, target: Vector3) -> void:
	var up_dir = Vector3(0, 1, 0)
	var cur_dir = position.basis * (Vector3(0, 0, 1))
	var target_dir = (target - position.origin).normalized()
	var rotation_angle = acos(cur_dir.x) - acos(target_dir.x)
	state.set_angular_velocity(up_dir * (rotation_angle / state.get_step()))

func safe_look_at(spatial: Node3D, target: Vector3) -> void:
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

func slerp_look_at(spatial: Node3D, target: Vector3, speed: float) -> void:
		var global_pos = spatial.global_transform
		var dest_transform = global_pos
		if global_pos.origin != target:
			dest_transform = global_pos.looking_at(target, Vector3.UP)
		var dest_rotation = Quaternion(global_pos.basis).slerp(Quaternion(dest_transform.basis).normalized(), speed)
		spatial.global_transform = Transform3D(Basis(dest_rotation), global_pos.origin)

func find_target(node: Node3D, group_name: String, get_closest: = true) -> Node3D:
	var targets: Array = get_tree().get_nodes_in_group(group_name)
	if !targets.is_empty():
		var distance_away: float = node.global_transform.origin.distance_to(targets[0].global_transform.origin)
		var return_target: Node3D = targets[0]
		for i in targets.size():
			var distance: float = node.global_transform.origin.distance_to(targets[i].global_transform.origin)
			if get_closest == true and distance < distance_away:
				distance_away = distance
				return_target = targets[i]
			elif get_closest == false and distance > distance_away:
				distance_away = distance
				return_target = targets[i]
		return return_target
	return null

func apply_surface_align(tform: Transform3D, new_up: Vector3) -> Transform3D:
	tform.basis.y = new_up
	tform.basis.x = -tform.basis.z.cross(new_up)
	tform.basis = tform.basis.orthonormalized()
	return tform

#func degrees_to_cardinal(angle):
#	var directions = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
#	var i = int(round(angle / (360 / len(directions))))
#	return directions[i % 8]

static func cardinal_to_degrees(direction: String) -> int:
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

func get_files(folder_path: String, path: bool = false, recursive: bool = true) -> Array:
	var dir := DirAccess.open(folder_path)
	if dir:
		printerr("Could not open directory: ", folder_path)
		return []
	if dir.list_dir_begin()  != OK:# TODOConverter3To4 fill missing arguments https://github.com/godotengine/godot/pull/40547
		printerr("Could not list contents of: ", folder_path)
		return []
	var files := []
	var file_name := dir.get_next()
	while file_name != "":
		if file_name.get_extension() != ".import":
			if dir.current_is_dir():
				if recursive:
					var dir_path = dir.get_current_dir() + "/" + file_name
					files += get_files(dir_path, recursive)
			else:
				var file_path = dir.get_current_dir() + "/" + file_name
				if path:
					files.append(file_path)
				else:
					var file := FileAccess.open(file_path, FileAccess.READ)
					if file:
						files.append(file)
					else:
						printerr("Could not open file: ", file_path)
			file_name = dir.get_next()
	return files

func get_names_from_paths(folder_path: String, extension: String) -> PackedStringArray:
	var arr = Utility.get_files(folder_path, true, false)
	var new_arr: PackedStringArray = []
	for e in arr:
		e.erase(0, folder_path.length())
		e.erase(e.length() - extension.length(), extension.length())
		new_arr.append(e)
	return new_arr

func read_config(path: String, section: String, key: String):
	var config = ConfigFile.new()
	config.load(path)
	if config.has_section(section) and config.has_section_key(section, key):
		var value = config.get_value(section, key)
		return value
	else:
		printerr("Config file section or key not found")
		return null

func pause(toggle: bool) -> void:
	if toggle:
		get_tree().set_deferred("paused", true)
	else:
		get_tree().set_deferred("paused", false)

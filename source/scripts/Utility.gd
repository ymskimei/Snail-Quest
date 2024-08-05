extends Node

var rng = RandomNumberGenerator.new()

## Math Functions ##

func normalize_range(value: float, min_value: float, max_value: float) -> float:
	return (value - min_value) / (max_value - min_value)

func adjusted_range(value: float, min_in: float, max_in: float, min_out: float, max_out: float):
	return min_out + (value - min_in) * (max_out - min_out) / (max_in - min_in)

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

func get_group_by_nearest(node: Spatial, group_name: String) -> Array:
	var targets: Array = get_tree().get_nodes_in_group(group_name)
	targets.sort_custom(self, "compare_distance")
	return targets

func compare_distance(a: Spatial, b: Spatial) -> bool:
	var c = SnailQuest.controlled.global_transform.origin
	if a.global_transform.origin.distance_to(c) < b.global_transform.origin.distance_to(c):
		return true
	return false

func apply_surface_align(tform: Transform, new_up: Vector3) -> Transform:
	tform.basis.y = new_up
	tform.basis.x = -tform.basis.z.cross(new_up)
	tform.basis = tform.basis.orthonormalized()
	return tform

static func degrees_to_cardinal(angle: float) -> String:
	var directions = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
	var i = int(round(angle / (360 / len(directions))))
	return directions[i % 8]

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

## Time and Date ##

func get_time_as_clock(raw_time: int, hour_24: bool = true) -> String:
	var time: Array = raw_time_to_array(raw_time, hour_24)
	if hour_24:
		return "%02d:%02d" % [time[0], time[1]]
	else:
		return "%02d:%02d%s" % [time[0], time[1], time[3]]

func get_time_as_count(raw_time: int) -> String:
	var time: Array = raw_time_to_array(raw_time, true, true)
	return "%02dh, %02dm, %02ds" % [time[0], time[1], time[2]]

func raw_time_to_array(raw_time: int = 0, hour_24: bool = true, real_time: bool = false) -> Array:
	var second: int = 0
	var minute: int = raw_time % 60
	var hour: int = int(raw_time / 60)
	if real_time:
		second = raw_time / 1000 % 60
		minute = (raw_time / 1000 / 60) % 60
		hour = (raw_time / 1000 / 60) / 60
	if hour_24:
		return [hour, minute, second, ""]
	else:
		var period = "AM"
		if hour >= 12:
			hour = hour % 12
			period = "PM"
		if hour == 0: 
			hour = 12
		return [hour, minute, second, period]

func get_number_with_suffix(n: int) -> String:
	var suffixes = ["st", "nd", "rd"]
	var suffix = "th"
	if n % 10 == 1 and n % 100 != 11:
		suffix = suffixes[0]
	elif n % 10 == 2 and n % 100 != 12:
		suffix = suffixes[1]
	elif n % 10 == 3 and n % 100 != 13:
		suffix = suffixes[2]
	return str(n) + suffix

func first_year() -> int:
	return 2006

func days_to_date(days_elapsed: int) -> Array:
	var days_per_month = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
	var days_in_year = 365

	var years_elapsed = 0

	while days_elapsed >= days_in_year:
		if is_leap_year(years_elapsed):
			days_in_year = 366
		else:
			days_in_year = 365

		if days_elapsed >= days_in_year:
			days_elapsed -= days_in_year
			years_elapsed += 1

	var months_elapsed = 0

	if is_leap_year(years_elapsed):
		days_per_month[1] = 29

	while months_elapsed < 12 and days_elapsed >= days_per_month[months_elapsed]:
		days_elapsed -= days_per_month[months_elapsed]
		months_elapsed += 1

	return [years_elapsed, months_elapsed, days_elapsed]

func is_leap_year(year: int) -> bool:
	var y = year + first_year()
	return (y % 4 == 0) and (y % 100 != 0 or (y % 400 == 0))

func get_day_from_integer(days_elapsed: int) -> int:
	var days_of_week: Array = [0, 1, 2, 3, 4, 5, 6]
	#first int is for the first day of the counter
	return days_of_week[(days_of_week.find(0) + days_elapsed) % 7]

func get_date_info(variable: int, calculator: String) -> String:
	var result: String
	var months: Array = [
		"January", "February", "March", "April",
		"May", "June", "July", "August",
		"September", "October", "November", "December"]
	var weekdays: Array = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
	match calculator:
		"year":
			result = str(first_year() + variable)
		"month":
			if variable < months.size():
				result = months[variable]
			else:
				result = "Invalid month"
		"weekday":
			if variable < weekdays.size():
				result = weekdays[variable]
			else:
				result = "Invalid weekday"
		_:
			result = "Invalid calc type"
	return result

func basic_date_string(days_elapsed: int) -> String:
	var days_to_date: Array = days_to_date(days_elapsed)

	var year_string: String = get_date_info(days_to_date[0], "year")
	var month_string: String = get_date_info(days_to_date[1], "month")
	var day_string: String = get_number_with_suffix(days_to_date[2] + 1)

	var weekday_string: String = get_date_info(get_day_from_integer(days_elapsed), "weekday")

	return weekday_string + ", " + month_string + " " + day_string + ", " + year_string

## File Managing ##

func get_files(folder_path: String, path: bool = false, recursive: bool = true) -> Array:
	var dir := Directory.new()
	if dir.open(folder_path) != OK:
		printerr("Could not open directory: ", folder_path)
		return []
	if dir.list_dir_begin(true, true) != OK:
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
					var file := File.new()
					if file.open(file_path, File.READ) == OK:
						files.append(file)
					else:
						printerr("Could not open file: ", file_path)
			file_name = dir.get_next()
	return files

func get_names_from_paths(folder_path: String, extension: String) -> PoolStringArray:
	var arr = get_files(folder_path, true, false)
	var new_arr: PoolStringArray = []
	for e in arr:
		e.erase(0, folder_path.length())
		e.erase(e.length() - extension.length(), extension.length())
		new_arr.append(e)
	return new_arr

func get_loaded_files(load_path, type: String, extension: String) -> Array:
	var arr: Array = []
	for m in get_files(load_path, true, true):
		if m.begins_with(load_path + type) and m.ends_with(extension):
			arr.append(load(m))
	return arr

func array_cycle(current, arr: Array, next: bool) -> int:
	var index = arr.find(current)
	if next:
		index = (index + 1) % arr.size()
	else:
		index = (index - 1 + arr.size()) % arr.size()
	return index

func read_config(path: String, section: String, key: String):
	var config = ConfigFile.new()
	config.load(path)
	if config.has_section(section) and config.has_section_key(section, key):
		var value = config.get_value(section, key)
		return value
	else:
		printerr("Config file section or key not found")
		return null

## Misc Functions ##

func damage(host: Spatial, size: Vector3 = Vector3(1.0, 1.0, 1.0), amount: float = 1.0, impact_pause: float = 0.0) -> void:
	var damager: Area = load("res://source/scenes/entity/damager.tscn").instance()
	host.add_child(damager)

	damager.set_global_translation(host.get_global_translation())
	damager.mesh.set_scale(size)
	damager.collision.set_scale(size)
	damager.set_damage_amount(amount)

func kinematic_to_physics_body(kinematic_body: Entity) -> RigidBody:
	var physics_body: RigidBody = kinematic_body.get_physics_body().instance()
	physics_body.set_entity_identity(kinematic_body.get_entity_identity())

	return physics_body

func physics_to_kinematic_body(physics_body: RigidBody) -> KinematicBody:
	var kinematic_body: KinematicBody = physics_body.get_kinematic_body().instance()
	kinematic_body.set_entity_identity(physics_body.get_entity_identity())

	return kinematic_body

func pause(toggle: bool) -> void:
	if toggle:
		get_tree().set_deferred("paused", true)
	else:
		get_tree().set_deferred("paused", false)

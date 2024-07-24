extends Node

export var environment_colors: Texture

onready var sky: MeshInstance = $MeshInstance

var light_sources: Array = []
var sky_gradient: Gradient 

func _ready() -> void:
	sky_gradient = sky.get_surface_material(0).get_shader_param("albedo").get_gradient()

func _physics_process(delta: float) -> void:
	var time_dawn: int = 300
	var time_day: int = 600
	var time_twili: int = 900
	var time_night: int = 1200

	var time: int = time_day
	if is_instance_valid(SnailQuest.get_game_time()):
		time = SnailQuest.get_game_time().get_raw_time()

	var modifier: int = 0

	var current_sky_color: Color
	var current_horizon_color: Color

	if time in range(0, time_dawn):
		current_sky_color = lerp(get_color_value(0, 3 + modifier), get_color_value(0, 0 + modifier), Utility.normalize_range(time, 0, time_dawn))
		current_horizon_color = lerp(get_color_value(1, 3 + modifier), get_color_value(1, 0 + modifier), Utility.normalize_range(time, 0, time_dawn))
	elif time in range(time_dawn, time_day):
		current_sky_color = lerp(get_color_value(0, 0 + modifier), get_color_value(0, 1 + modifier), Utility.normalize_range(time, time_dawn, time_day))
		current_horizon_color = lerp(get_color_value(1, 0 + modifier), get_color_value(1, 1 + modifier), Utility.normalize_range(time, time_dawn, time_day))
	elif time in range(time_day, time_twili):
		current_sky_color = lerp(get_color_value(0, 1 + modifier), get_color_value(0, 2 + modifier), Utility.normalize_range(time, time_day, time_twili))
		current_horizon_color = lerp(get_color_value(1, 1 + modifier), get_color_value(1, 2 + modifier), Utility.normalize_range(time, time_day, time_twili))
	elif time in range(time_twili, 1200):
		current_sky_color = lerp(get_color_value(0, 2 + modifier), get_color_value(0, 3 + modifier), Utility.normalize_range(time, time_twili, time_night))
		current_horizon_color = lerp(get_color_value(1, 2 + modifier), get_color_value(1, 3 + modifier), Utility.normalize_range(time, time_twili, time_night))

	sky_gradient.set_color(0, current_sky_color)
	sky_gradient.set_color(1, current_horizon_color)
	sky_gradient.set_color(2, current_sky_color)

func get_color_value(x: int, y: int) -> Color:
	var c_map = environment_colors.get_data()
	c_map.lock()
	return c_map.get_pixel(x, y)

func make_material_unique(base_material: Material) -> Material:
	if base_material.get_shader().has_param("light_direction"):
		var new_material: Material = base_material.duplicate()
		return new_material
	return base_material

func track_light_source(delta, self_location: Vector3, material: Material) -> void:
	var closest_light: Spatial
	var closest_light_distance: float
	var closest_light_direction: Vector3
	var minimum_distance = INF

	for l in light_sources:
		var distance = l.get_global_translation().distance_to(self_location)
		if distance < 16.0:
			if distance < minimum_distance:
				minimum_distance = distance
				closest_light = l
		else:
			closest_light = null

	if material.get_shader().has_param("light_direction"):
		var new_light_direction: Vector3
		if closest_light:
			new_light_direction = -(self_location - closest_light.get_global_translation()).normalized()
		else:
			new_light_direction = Vector3.UP
		closest_light_direction = lerp(material.get_shader_param("light_direction"), new_light_direction, 6.0 * delta)
		material.set_shader_param("light_direction", closest_light_direction)

	#Chucky wrote this:
	#*************///////////////////////////////------------
	#--------------------------------------------------------
	#--------------------------------------------------------
	#----------rttttt--------[[[[[[[[[[[[[]*]]]]]]]]]]]]

func reload_light_sources(scene: Spatial) -> void:
	light_sources.clear()
	light_sources = _get_light_sources(scene)
	print(light_sources)

func _get_light_sources(node: Node) -> Array:
	var result: Array = []
	for n in node.get_children():
		if n.is_in_group("light"):
			result.append(n)
		_get_light_sources(n)
	return result

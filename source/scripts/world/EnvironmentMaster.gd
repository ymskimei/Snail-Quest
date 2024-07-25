extends Spatial

export var environment_colors: Texture

onready var sky: MeshInstance = $MeshInstance

var light_sources: Array = []
var sky_gradient: Gradient 

var time: int

var time_dawn: int = 360
var time_day: int = 720
var time_twili: int = 1080
var time_night: int = 1440

func _ready() -> void:
	sky_gradient = sky.get_surface_material(0).get_shader_param("texture_albedo").get_gradient()

func _physics_process(delta: float) -> void:
	if is_instance_valid(SnailQuest.get_game_time()):
		time = SnailQuest.get_game_time().get_raw_time()

	if is_instance_valid(SnailQuest.get_controlled()):
		var c = SnailQuest.get_controlled().get_global_translation()
		sky.set_global_translation(Vector3(c.x, 0, c.z))

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
	elif time in range(time_twili, 1440):
		current_sky_color = lerp(get_color_value(0, 2 + modifier), get_color_value(0, 3 + modifier), Utility.normalize_range(time, time_twili, time_night))
		current_horizon_color = lerp(get_color_value(1, 2 + modifier), get_color_value(1, 3 + modifier), Utility.normalize_range(time, time_twili, time_night))

	sky_gradient.set_color(0, current_sky_color)
	sky_gradient.set_color(1, current_horizon_color)
	sky_gradient.set_color(2, current_sky_color)

func get_color_value(x: int, y: int) -> Color:
	var c_map = environment_colors.get_data()
	c_map.lock()
	return c_map.get_pixel(x, y)

func get_material_color(original_color: Color) -> Array:
	var blendable_highlight_color: Color
	var blendable_albedo_color: Color
	var blendable_shade_color: Color

	if time in range(0, time_dawn):
		blendable_highlight_color = lerp(get_color_value(0, 15), get_color_value(0, 12), Utility.normalize_range(time, 0, time_dawn))
		blendable_albedo_color = lerp(get_color_value(1, 15), get_color_value(1, 12), Utility.normalize_range(time, 0, time_dawn))
		blendable_shade_color = lerp(get_color_value(2, 15), get_color_value(1, 12), Utility.normalize_range(time, 0, time_dawn))
	elif time in range(time_dawn, time_day):
		blendable_highlight_color = lerp(get_color_value(0, 12), original_color, Utility.normalize_range(time, time_dawn, time_day))
		blendable_albedo_color = lerp(get_color_value(1, 12), original_color, Utility.normalize_range(time, time_dawn, time_day))
		blendable_shade_color = lerp(get_color_value(1, 12), original_color, Utility.normalize_range(time, time_dawn, time_day))
	elif time in range(time_day, time_twili):
		blendable_highlight_color = lerp(original_color, get_color_value(0, 14), Utility.normalize_range(time, time_day, time_twili))
		blendable_albedo_color = lerp(original_color, get_color_value(1, 14), Utility.normalize_range(time, time_day, time_twili))
		blendable_shade_color = lerp(original_color, get_color_value(1, 14), Utility.normalize_range(time, time_day, time_twili))
	elif time in range(time_twili, 1440):
		blendable_highlight_color = lerp(get_color_value(0, 14), get_color_value(0, 15), Utility.normalize_range(time, time_twili, time_night))
		blendable_albedo_color = lerp(get_color_value(1, 14), get_color_value(1, 15), Utility.normalize_range(time, time_twili, time_night))
		blendable_shade_color = lerp(get_color_value(1, 14), get_color_value(1, 15), Utility.normalize_range(time, time_twili, time_night))

	var new_highlight_color: Color = original_color.blend(Color(blendable_highlight_color.r, blendable_highlight_color.g, blendable_highlight_color.b, 0.45))
	var new_albedo_color: Color = original_color.blend(Color(blendable_albedo_color.r, blendable_albedo_color.g, blendable_albedo_color.b, 0.45))
	var new_shade_color: Color = original_color.blend(Color(blendable_shade_color.r, blendable_shade_color.g, blendable_shade_color.b, 0.45))

	return [new_highlight_color, new_albedo_color, new_shade_color]

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

func _get_light_sources(node: Node) -> Array:
	var result: Array = []
	for n in node.get_children():
		if n.is_in_group("light"):
			result.append(n)
		_get_light_sources(n)
	return result

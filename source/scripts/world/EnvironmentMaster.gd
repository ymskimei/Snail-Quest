extends Spatial

export var environment_colors: Texture

onready var light: Position3D = $Light
onready var orbital: Position3D = $Orbital
onready var sky: MeshInstance = $MeshInstance

var sky_gradient: Gradient 
var c_map: Image

var time: float

var time_dawn: int = 360
var time_day: int = 720
var time_twili: int = 1080
var time_night: int = 1440

var light_sources: Array = []

func _ready() -> void:
	sky_gradient = sky.get_surface_material(0).get_shader_param("texture_albedo").get_gradient()

	c_map = environment_colors.get_data()
	c_map.lock()

func _physics_process(delta: float) -> void:
	if is_instance_valid(SnailQuest.get_game_time()):
		time = SnailQuest.get_game_time().get_raw_time()

	if is_instance_valid(SnailQuest.get_controlled()):
		var c = SnailQuest.get_controlled().get_global_translation()
		sky.set_global_translation(Vector3(c.x, 0, c.z))

	var modifier: int = 0

	var current_sky_color: Color
	var current_horizon_color: Color

	var fade_margin = 20

	if time in range(0, time_dawn):
		var time_range: float = Utility.normalize_range(time, 0, time_dawn)

		light.get_child(0).set_color(lerp(get_color_value(0, 3 + modifier), get_color_value(0, 0 + modifier), time_range))
		light.rotation.z = lerp(deg2rad(-90), deg2rad(-170), time_range)
		current_sky_color = lerp(get_color_value(1, 3 + modifier), get_color_value(1, 0 + modifier), time_range)
		current_horizon_color = lerp(get_color_value(2, 3 + modifier), get_color_value(2, 0 + modifier), time_range)

		if time in range(time_dawn - fade_margin, time_dawn):
			light.get_child(0).light_energy = lerp(1.75, 0.0, Utility.normalize_range(time, time_dawn - fade_margin, time_dawn))

	elif time in range(time_dawn, time_day):
		var time_range: float = Utility.normalize_range(time, time_dawn, time_day)

		light.get_child(0).set_color(lerp(get_color_value(0, 0 + modifier), get_color_value(0, 1 + modifier), time_range))
		light.rotation.z = lerp(deg2rad(-10), deg2rad(-90), time_range)
		current_sky_color = lerp(get_color_value(1, 0 + modifier), get_color_value(1, 1 + modifier), time_range)
		current_horizon_color = lerp(get_color_value(2, 0 + modifier), get_color_value(2, 1 + modifier), time_range)

		if time in range(time_dawn, time_dawn + fade_margin):
			light.get_child(0).light_energy = lerp(0.0, 1.75, Utility.normalize_range(time, time_dawn, time_dawn + fade_margin))

	elif time in range(time_day, time_twili):
		var time_range: float = Utility.normalize_range(time, time_day, time_twili)

		light.get_child(0).set_color(lerp(get_color_value(0, 1 + modifier), get_color_value(0, 2 + modifier), time_range))
		light.rotation.z = lerp(deg2rad(-90), deg2rad(-170), time_range)
		current_sky_color = lerp(get_color_value(1, 1 + modifier), get_color_value(1, 2 + modifier), time_range)
		current_horizon_color = lerp(get_color_value(2, 1 + modifier), get_color_value(2, 2 + modifier), time_range)

		if time in range(time_twili - fade_margin, time_twili):
			light.get_child(0).light_energy = lerp(1.75, 0.0, Utility.normalize_range(time, time_twili - fade_margin, time_twili))
		
	elif time in range(time_twili, time_night):
		var time_range: float = Utility.normalize_range(time, time_twili, time_night)

		light.get_child(0).set_color(lerp(get_color_value(0, 2 + modifier), get_color_value(0, 3 + modifier), time_range))
		light.rotation.z = lerp(deg2rad(-10), deg2rad(-90), time_range)
		current_sky_color = lerp(get_color_value(1, 2 + modifier), get_color_value(1, 3 + modifier), time_range)
		current_horizon_color = lerp(get_color_value(2, 2 + modifier), get_color_value(2, 3 + modifier), time_range)

		if time in range(time_twili, time_twili + fade_margin):
			light.get_child(0).light_energy = lerp(0.0, 1.75, Utility.normalize_range(time, time_twili, time_twili + fade_margin))
	
	if time in range (0, time_day):
		var time_range: float = Utility.normalize_range(time, 0, time_day)
		orbital.rotation.z = lerp_angle(deg2rad(-180), deg2rad(0), time_range)

	elif time in range (time_day, time_night):
		var time_range: float = Utility.normalize_range(time, time_day, time_night)
		orbital.rotation.z = lerp_angle(deg2rad(0), deg2rad(180), time_range)
	
	sky_gradient.set_color(0, current_sky_color)
	sky_gradient.set_color(1, current_horizon_color)
	sky_gradient.set_color(2, current_sky_color)

	#orbital.rotation.x = lerp_angle(orbital.rotation.x, (-180 * PI / 180) + (day_percentage * (2 * PI)), 0.01)

func get_color_value(x: int, y: int) -> Color:
	return c_map.get_pixel(x, y)
#
#func get_material_color(original_color: Color) -> Array:
#	var blendable_highlight_color: Color
#	var blendable_albedo_color: Color
#	var blendable_shade_color: Color
#
#	if time in range(0, time_dawn):
#		blendable_highlight_color = lerp(get_color_value(0, 15), get_color_value(0, 12), Utility.normalize_range(time, 0, time_dawn))
#		blendable_albedo_color = lerp(get_color_value(1, 15), get_color_value(1, 12), Utility.normalize_range(time, 0, time_dawn))
#		blendable_shade_color = lerp(get_color_value(2, 15), get_color_value(1, 12), Utility.normalize_range(time, 0, time_dawn))
#	elif time in range(time_dawn, time_day):
#		blendable_highlight_color = lerp(get_color_value(0, 12), original_color, Utility.normalize_range(time, time_dawn, time_day))
#		blendable_albedo_color = lerp(get_color_value(1, 12), original_color, Utility.normalize_range(time, time_dawn, time_day))
#		blendable_shade_color = lerp(get_color_value(1, 12), original_color, Utility.normalize_range(time, time_dawn, time_day))
#	elif time in range(time_day, time_twili):
#		blendable_highlight_color = lerp(original_color, get_color_value(0, 14), Utility.normalize_range(time, time_day, time_twili))
#		blendable_albedo_color = lerp(original_color, get_color_value(1, 14), Utility.normalize_range(time, time_day, time_twili))
#		blendable_shade_color = lerp(original_color, get_color_value(1, 14), Utility.normalize_range(time, time_day, time_twili))
#	elif time in range(time_twili, 1440):
#		blendable_highlight_color = lerp(get_color_value(0, 14), get_color_value(0, 15), Utility.normalize_range(time, time_twili, time_night))
#		blendable_albedo_color = lerp(get_color_value(1, 14), get_color_value(1, 15), Utility.normalize_range(time, time_twili, time_night))
#		blendable_shade_color = lerp(get_color_value(1, 14), get_color_value(1, 15), Utility.normalize_range(time, time_twili, time_night))
#
#	var new_highlight_color: Color = original_color.blend(Color(blendable_highlight_color.r, blendable_highlight_color.g, blendable_highlight_color.b, 0.45))
#	var new_albedo_color: Color = original_color.blend(Color(blendable_albedo_color.r, blendable_albedo_color.g, blendable_albedo_color.b, 0.45))
#	var new_shade_color: Color = original_color.blend(Color(blendable_shade_color.r, blendable_shade_color.g, blendable_shade_color.b, 0.45))
#
#	return [new_highlight_color, new_albedo_color, new_shade_color]

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

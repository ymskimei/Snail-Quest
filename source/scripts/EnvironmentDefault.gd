extends Spatial

onready var sky: MeshInstance = $Sky
onready var orbital: Spatial = $Orbital
onready var light: DirectionalLight = $DirectionalLight
onready var environment: WorldEnvironment = $WorldEnvironment
onready var cloud_area: Area = $Area
onready var star_particles: Node2D = $Viewport/Stars

export(Resource) var environment_current

export(Resource) var environment_clear
export(Resource) var environment_cloud

export(Resource) var colors_dawn
export(Resource) var colors_day
export(Resource) var colors_twilight
export(Resource) var colors_night

var sky_color_1: Color
var sky_color_2: Color
var cloud_color: Color
var ambient_color: Color
var light_color: Color
var fog_color: Color
var fog_depth: int
var stars_level: int

export var cloud: PackedScene
export var all_clouds: Array
export var max_clouds: int = 64

export var full_cycle: int = 1440
export var half_cycle: int = 720
export var time_dawn: int = 360
export var time_day: int = 480
export var time_twilight: int = 960
export var time_night: int = 1080
export var transition_speed: int = 15

var time: int = 0

func _ready() -> void:
	var cloud_timer = Timer.new()
	cloud_timer.set_wait_time(2)
	cloud_timer.connect("timeout", self, "on_cloud_timer")
	add_child(cloud_timer)
	cloud_timer.start()

func _physics_process(delta: float) -> void:
	if is_instance_valid(GlobalManager.game_time):
		time = GlobalManager.game_time.get_raw_time()
		set_orbit(delta)
		set_environment(delta)
		set_environment_by_time()

func set_environment_by_time() -> void:
	if time in range(time_dawn, time_day):
		environment_clear = colors_dawn
		environment_cloud = colors_dawn
	elif time in range(time_day, time_twilight):
		environment_clear = colors_day
		environment_cloud = colors_day
	elif time in range(time_twilight, time_night):
		environment_clear = colors_twilight
		environment_cloud = colors_twilight
	else:
		environment_clear = colors_night
		environment_cloud = colors_night
	environment_current = environment_clear 
	check_environment_variables()

func check_environment_variables() -> void:
	sky_color_1 = environment_current.sky_color_1
	sky_color_2 = environment_current.sky_color_2
	cloud_color = environment_current.cloud_color
	ambient_color = environment_current.ambient_color
	light_color = environment_current.light_color
	fog_color = environment_current.fog_color
	fog_depth = environment_current.fog_depth
	stars_level = environment_current.stars_level

func on_cloud_timer() -> void:
	randomize()
	var x_range = Vector2(-2560, 2560)
	var y_range = Vector2(-2560, 2560)
	var random_x = randi() % int(x_range[1]- x_range[0]) + 1 + x_range[0]
	var random_y =  randi() % int(y_range[1]-y_range[0]) + 1 + y_range[0]
	var random_pos = Vector3(random_x, rand_range(512, 578), random_y)
	var new_cloud = cloud.instance()
	var r_size = rand_range(0.25, 2)
	var r_width = rand_range(1, 2)
	if all_clouds.size() > max_clouds:
		all_clouds.pop_front().fade_away()
	all_clouds.append(new_cloud)
	cloud_area.add_child(new_cloud)
	new_cloud.scale = Vector3(r_size + r_width, r_size, r_size + r_width)
	new_cloud.translation = random_pos
	new_cloud.sprite.modulate = cloud_color

func set_orbit(delta: float) -> void:
	var day_percentage = float(time) / full_cycle
	var camera_pos = GlobalManager.camera.camera_lens.global_translation
	if camera_pos != null:
		orbital.global_translation = camera_pos
		sky.global_translation = lerp(sky.global_translation, Vector3(camera_pos.x, camera_pos.y + 15, camera_pos.z), 0.9)
	orbital.rotation.x = lerp_angle(orbital.rotation.x, (-180 * PI / 180) + (day_percentage * (2 * PI)), 0.01)
	if time in range (360, 1080):
		light.rotation.x = lerp_angle(light.rotation.x, (180 * PI / 180) + (day_percentage * 4), 0.5 * delta)
	elif time >= time_night:
		light.rotation.x = lerp_angle(light.rotation.x, (360 * PI / 180) + (day_percentage * 4), 0.5 * delta)

func set_environment(delta: float):
	var current_sky_color = sky.get_surface_material(0).albedo_texture.get_gradient()
	var current_ambient_color = environment.environment.ambient_light_color
	var current_light_color = light.light_color
	var current_fog_color = environment.environment.fog_color
	var current_fog_depth = environment.environment.fog_depth_end
	current_sky_color.set_color(0, lerp(current_sky_color.get_color(0), sky_color_1, 0.5 * delta))
	current_sky_color.set_color(1, lerp(current_sky_color.get_color(1), sky_color_2, 0.5 * delta))
	current_ambient_color = lerp(current_ambient_color, ambient_color, 0.1 * delta)
	current_light_color = lerp(current_light_color, light_color, 0.1 * delta)
	current_fog_color = lerp(current_fog_color, fog_color, 0.1 * delta)
	current_fog_depth = lerp(current_fog_depth, fog_depth, 0.1 * delta)
	for c in all_clouds:
		if c.sprite.modulate != cloud_color:
			c.sprite.modulate = lerp(c.sprite.modulate, cloud_color, 1 * delta)
	if stars_level == 2:
		star_particles.modulate = lerp(star_particles.modulate, Color("FFFFFF"), 1 * delta)
	elif stars_level == 1:
		star_particles.modulate = lerp(star_particles.modulate, Color("77FFFFFF"), 1 * delta)
	else:
		star_particles.modulate = lerp(star_particles.modulate, Color("00FFFFFF"), 1 * delta)

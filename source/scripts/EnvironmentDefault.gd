 extends Spatial

onready var sky: MeshInstance = $Sky
onready var orbital: Spatial = $Orbital
onready var light: DirectionalLight = $DirectionalLight
onready var environment: WorldEnvironment = $WorldEnvironment
onready var clouds: Position3D = $Clouds
onready var downpour: Position3D = $Downpour
onready var star_particles: Node2D = $Viewport/Stars

export(Resource) var environment_current
export(Resource) var environment_clear
export(Resource) var environment_storm
export(Resource) var colors_dawn_clear
export(Resource) var colors_dawn_storm
export(Resource) var colors_day_clear
export(Resource) var colors_day_storm
export(Resource) var colors_twilight_clear
export(Resource) var colors_twilight_storm
export(Resource) var colors_night_clear
export(Resource) var colors_night_storm

var sky_color_1: Color
var sky_color_2: Color
var cloud_color: Color
var ambient_color: Color
var light_color: Color
var fog_color: Color
var fog_depth_begin: int
var fog_depth_end: int
var stars_level: int

export var cloud: PackedScene
export var rain_drop: PackedScene
export var all_clouds: Array
export var all_downpour: Array
export var max_clouds: int = 64

export var cloud_range_height: int = 1280
export var cloud_range_width: int = 2560
export var rain_range_width: int = 256

export var full_cycle: int = 1440
export var half_cycle: int = 720
export var time_dawn: int = 360
export var time_day: int = 480
export var time_twilight: int = 960
export var time_night: int = 1080

export var transition_speed: int = 5
export var storm_frequency: int = 10

var time: int = 0
var cloudy: bool

func _ready() -> void:
	var cloud_timer = Timer.new()
	cloud_timer.set_wait_time(3)
	cloud_timer.connect("timeout", self, "on_cloud_timer")
	add_child(cloud_timer)
	cloud_timer.start()
	var rain_timer = Timer.new()
	rain_timer.set_wait_time(0.5)
	rain_timer.connect("timeout", self, "on_rain_timer")
	add_child(rain_timer)
	rain_timer.start()
	var weather_timer = Timer.new()
	weather_timer.set_wait_time(60)
	weather_timer.connect("timeout", self, "on_weather_timer")
	add_child(weather_timer)
	weather_timer.start()

func _physics_process(delta: float) -> void:
	if is_instance_valid(SB.game_time):
		time = SB.game_time.get_raw_time()
		set_orbit(delta)
		set_environment(delta)
		set_environment_by_time()

func set_environment_by_time() -> void:
	if time in range(time_dawn, time_day):
		environment_clear = colors_dawn_clear
		environment_storm = colors_dawn_storm
	elif time in range(time_day, time_twilight):
		environment_clear = colors_day_clear
		environment_storm = colors_day_storm
	elif time in range(time_twilight, time_night):
		environment_clear = colors_twilight_clear
		environment_storm = colors_twilight_storm
	else:
		environment_clear = colors_night_clear
		environment_storm = colors_night_storm
	if cloudy:
		environment_current = environment_storm
	else:
		environment_current = environment_clear
	check_environment_variables()

func check_environment_variables() -> void:
	sky_color_1 = environment_current.sky_color_1
	sky_color_2 = environment_current.sky_color_2
	cloud_color = environment_current.cloud_color
	ambient_color = environment_current.ambient_color
	light_color = environment_current.light_color
	fog_color = environment_current.fog_color
	fog_depth_begin = environment_current.fog_depth_begin
	fog_depth_end = environment_current.fog_depth_end
	stars_level = environment_current.stars_level

func set_orbit(delta: float) -> void:
	var day_percentage = float(time) / full_cycle
	var camera_pos = SB.camera.camera_lens.global_translation
	if camera_pos != null:
		orbital.global_translation = camera_pos
		sky.global_translation = lerp(sky.global_translation, Vector3(camera_pos.x, camera_pos.y + 15, camera_pos.z), 0.9)
		downpour.global_translation = camera_pos + Vector3(0, 256, 0)
	orbital.rotation.x = lerp_angle(orbital.rotation.x, (-180 * PI / 180) + (day_percentage * (2 * PI)), 0.01)
	if time in range (360, 1080):
		light.rotation.x = lerp_angle(light.rotation.x, (180 * PI / 180) + (day_percentage * 4), 0.5 * delta)
	elif time >= time_night:
		light.rotation.x = lerp_angle(light.rotation.x, (360 * PI / 180) + (day_percentage * 4), 0.5 * delta)

func set_environment(delta: float):
	var current_sky_color = sky.get_surface_material(0).albedo_texture.get_gradient()
	var current_light_color = light.light_color
	var current_ambient_color = environment.environment.ambient_light_color
	var current_fog_color = environment.environment.fog_color
	var current_fog_depth_begin = environment.environment.fog_depth_begin
	var current_fog_depth_end = environment.environment.fog_depth_end
	current_sky_color.set_color(0, lerp(current_sky_color.get_color(0), sky_color_1, 1 * delta))
	current_sky_color.set_color(1, lerp(current_sky_color.get_color(1), sky_color_2, 1 * delta))
	current_sky_color.set_color(2, lerp(current_sky_color.get_color(2), sky_color_1, 1 * delta))
	for c in all_clouds:
		if c.sprite.modulate != cloud_color:
			c.sprite.modulate = lerp(c.sprite.modulate, cloud_color, 1 * delta)
	if stars_level == 2:
		star_particles.modulate = lerp(star_particles.modulate, Color("FFFFFF"), 1 * delta)
	elif stars_level == 1:
		star_particles.modulate = lerp(star_particles.modulate, Color("77FFFFFF"), 1 * delta)
	else:
		star_particles.modulate = lerp(star_particles.modulate, Color("00FFFFFF"), 1 * delta)
	$Tween.interpolate_property(light, "light_color", current_light_color, light_color, transition_speed, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.interpolate_property(environment.environment, "ambient_light_color", current_ambient_color, ambient_color, transition_speed, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.interpolate_property(environment.environment, "fog_color", current_fog_color, fog_color, transition_speed, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.interpolate_property(environment.environment, "fog_depth_begin", current_fog_depth_begin, fog_depth_begin, transition_speed, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.interpolate_property(environment.environment, "fog_depth_end", current_fog_depth_end, fog_depth_end, transition_speed, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()

func on_cloud_timer() -> void:
	#print(environment_current)
	randomize()
	var x_range = Vector2(-cloud_range_width, cloud_range_width)
	var y_range = Vector2(-cloud_range_width, cloud_range_width)
	var random_x = randi() % int(x_range[1]- x_range[0]) + 1 + x_range[0]
	var random_y =  randi() % int(y_range[1]-y_range[0]) + 1 + y_range[0]
	var random_pos = Vector3(random_x, cloud_range_height + rand_range(0, 50), random_y)
	var new_cloud = cloud.instance()
	var r_size = rand_range(0.25, 2)
	var r_width = rand_range(1, 2)
	if all_clouds.size() > max_clouds:
		all_clouds.pop_front().fade_away()
	all_clouds.append(new_cloud)
	new_cloud.scale = Vector3(r_size + r_width, r_size, r_size + r_width)
	new_cloud.translation = random_pos
	clouds.add_child(new_cloud)
	new_cloud.sprite.modulate = cloud_color

func on_rain_timer() -> void:
	var x_range = Vector2(-rain_range_width, rain_range_width)
	var y_range = Vector2(-rain_range_width, rain_range_width)
	var random_x = randi() % int(x_range[1]- x_range[0]) + 1 + x_range[0]
	var random_y =  randi() % int(y_range[1]-y_range[0]) + 1 + y_range[0]
	var random_pos = Vector3(random_x, cloud_range_height, random_y)
	var new_rain_drop = rain_drop.instance()
	if all_downpour.size() > 20:
		all_downpour.pop_front().queue_free()
	all_downpour.append(new_rain_drop)
	new_rain_drop.translation = random_pos
	downpour.add_child(new_rain_drop)

func on_weather_timer() -> void:
	randomize()
	var weather = randi() % 100
	if !cloudy:
		if weather <= storm_frequency:
			cloudy = true
		else:
			cloudy = false
	else:
		if weather <= (storm_frequency / 2):
			cloudy = false

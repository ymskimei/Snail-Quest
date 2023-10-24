extends Spatial

onready var sky: MeshInstance = $Sky
#onready var cloud_ring = $CloudRing
#onready var cloud_ring_2 = $CloudRing2
onready var orbital: Spatial = $Orbital
onready var light: DirectionalLight = $DirectionalLight
onready var environment: WorldEnvironment = $WorldEnvironment
onready var cloud_area: Area = $Area
onready var star_particles: Node2D = $Viewport/Stars

export var cloud: PackedScene
export var all_clouds: Array
export var max_clouds: int = 64

export var dawn_sky_color_1: Color = Color("BA84ED")
export var dawn_sky_color_2: Color = Color("FFC1D9")
export var dawn_cloud_color: Color = Color("C3BFFF")
export var dawn_ambient_color: Color = Color("F0C874")
export var dawn_light_color: Color = Color("9E9E9E")
export var dawn_fog_color: Color = Color("9FAB8B")

export var day_sky_color_1: Color = Color("3C9DFA")
export var day_sky_color_2: Color = Color("C6F2F7")
export var day_cloud_color: Color = Color("FFFFFF")
export var day_ambient_color: Color = Color("FFFFFF")
export var day_light_color: Color = Color("919181")
export var day_fog_color: Color = Color("899C99")

export var twili_sky_color_1: Color = Color("9563B7")
export var twili_sky_color_2: Color = Color("FFB868")
export var twili_cloud_color: Color = Color("FF8ED2")
export var twili_ambient_color: Color = Color("873232")
export var twili_light_color: Color = Color("C79D43")
export var twili_fog_color: Color = Color("CC9866")

export var night_sky_color_1: Color = Color("272C63")
export var night_sky_color_2: Color = Color("6D4193")
export var night_cloud_color: Color = Color("87647E")
export var night_ambient_color: Color = Color("443858")
export var night_light_color: Color = Color("262E3F")
export var night_fog_color: Color = Color("3D346B")

export var full_cycle: int = 1440
export var half_cycle: int = 720
export var dawn: int = 360
export var day: int = 480
export var twili: int = 960
export var night: int = 1080
export var transition_speed: int = 15

func _ready() -> void:
	var cloud_timer = Timer.new()
	cloud_timer.set_wait_time(2)
	cloud_timer.connect("timeout", self, "on_cloud_timer")
	add_child(cloud_timer)
	cloud_timer.start()

func _physics_process(delta: float) -> void:
	if is_instance_valid(GlobalManager.game_time):
		var time = GlobalManager.game_time.get_raw_time()
		check_orbit(time, delta)
		check_environment(time, delta)

func on_cloud_timer() -> void:
	randomize()
	var x_range = Vector2(-2560, 2560)
	var y_range = Vector2(-2560, 2560)
	var random_x = randi() % int(x_range[1]- x_range[0]) + 1 + x_range[0]
	var random_y =  randi() % int(y_range[1]-y_range[0]) + 1 + y_range[0]
	var random_pos = Vector3(random_x, rand_range(512, 578), random_y)
	var new_cloud = cloud.instance()
	if all_clouds.size() > max_clouds:
		all_clouds.pop_front().fade_away()
	all_clouds.append(new_cloud)
	new_cloud.translation = random_pos
	var r_size = rand_range(0.25, 2)
	var r_width = rand_range(1, 2)
	new_cloud.scale = Vector3(r_size + r_width, r_size, r_size + r_width)
	cloud_area.add_child(new_cloud)

func check_orbit(time: int, delta: float) -> void:
	var day_percentage = float(time) / full_cycle
	var camera_pos = GlobalManager.camera.camera_lens.global_translation
	if camera_pos != null:
		orbital.global_translation = camera_pos
		sky.global_translation = lerp(sky.global_translation, Vector3(camera_pos.x, camera_pos.y + 15, camera_pos.z), 0.9)
		#cloud_ring.global_translation = lerp(cloud_ring.global_translation, Vector3(camera_pos.x, 0, camera_pos.z), 0.9)
		#cloud_ring_2.global_translation = lerp(cloud_ring.global_translation, Vector3(camera_pos.x, 10, camera_pos.z), 0.9)
	#cloud_ring.rotation.y += -0.025 * delta
	#cloud_ring_2.rotation.y += 0.025 * delta
	orbital.rotation.x = lerp_angle(orbital.rotation.x, (-180 * PI / 180) + (day_percentage * (2 * PI)), 0.01)
	if time in range (360, 1080):
		light.rotation.x = lerp_angle(light.rotation.x, (180 * PI / 180) + (day_percentage * 4), 0.5 * delta)
	elif time >= night:
		light.rotation.x = lerp_angle(light.rotation.x, (360 * PI / 180) + (day_percentage * 4), 0.5 * delta)

func check_environment(time: int, delta: float):
	if time in range(dawn, day):
		change_environment(dawn_ambient_color, dawn_light_color, dawn_sky_color_1, dawn_sky_color_2, dawn_cloud_color, dawn_fog_color, 512, delta)
	elif time in range(day, twili):
		change_environment(day_ambient_color, day_light_color, day_sky_color_1, day_sky_color_2, day_cloud_color, day_fog_color, 2560, delta)
	elif time in range(twili, night):
		change_environment(twili_ambient_color, twili_light_color, twili_sky_color_1, twili_sky_color_2, twili_cloud_color, twili_fog_color, 2048, delta)
	else:
		change_environment(night_ambient_color, night_light_color, night_sky_color_1, night_sky_color_2, night_cloud_color, night_fog_color, 512, delta, true)

func change_environment(new_ambient_color: Color, new_light_color: Color, new_sky_color_1: Color, new_sky_color_2: Color, new_fog_color: Color, new_cloud_color: Color, new_fog_depth: int, delta: float, stars: bool = false):
	var sky_color = sky.get_surface_material(0).albedo_texture.get_gradient()
	var ambient_color = environment.environment.ambient_light_color
	var light_color = light.light_color
	var fog_color = environment.environment.fog_color
	var fog_depth_end = environment.environment.fog_depth_end
	sky_color.set_color(0, lerp(sky_color.get_color(0), new_sky_color_1, 0.5 * delta))
	sky_color.set_color(1, lerp(sky_color.get_color(1), new_sky_color_2, 0.5 * delta))
	for c in all_clouds:
		c.modulate.color = lerp(c.modulate.color, new_cloud_color, 0.1 * delta)
	if stars:
		star_particles.modulate = lerp(star_particles.modulate, Color("FFFFFF"), 0.1 * delta)
	else:
		star_particles.modulate = lerp(star_particles.modulate, Color("00FFFFFF"), 0.1 * delta)
	$Tween.interpolate_property(environment.environment, "ambient_light_color", ambient_color, new_ambient_color, transition_speed, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.interpolate_property(light, "light_color", light_color, new_light_color, transition_speed, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.interpolate_property(environment.environment, "fog_color", fog_color, new_fog_color, transition_speed, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.interpolate_property(environment.environment, "fog_depth_end", fog_depth_end, new_fog_depth, transition_speed, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()

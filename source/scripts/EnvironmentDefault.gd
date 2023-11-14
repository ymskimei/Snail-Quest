 extends Spatial

onready var sky = $"%Sky"
onready var clouds = $"%Clouds"
onready var clouds_front = $"%CloudsFront"
onready var clouds_back = $"%CloudsBack"
onready var orbital = $"%Orbital"
onready var light = $"%DirectionalLight"
onready var environment = $WorldEnvironment

export var dawn_sky_color = Color("B8CFD9")
export var dawn_ambient_color = Color("F0C874")
export var dawn_light_color = Color("9E9E9E")
export var dawn_fog_color = Color("9FAB8B")

export var day_sky_color = Color("70BFFF")
export var day_ambient_color = Color("FFFFFF")		
export var day_light_color = Color("919181")
export var day_fog_color = Color("899C99")

export var dusk_sky_color = Color("FAACB8")
export var dusk_ambient_color = Color("873232")
export var dusk_light_color = Color("C79D43")
export var dusk_fog_color = Color("CC9866")

export var night_sky_color = Color("261E41")
export var night_ambient_color = Color("443858")
export var night_light_color = Color("262E3F")
export var night_fog_color = Color("3D346B")

export var full_cycle = 1440
export var half_cycle = 720
export var dawn = 360
export var day = 480
export var dusk = 960
export var night = 1080	
export var transition_speed = 15

func _physics_process(delta):
	if is_instance_valid(GlobalManager.game_time):
		var time = GlobalManager.game_time.get_raw_time()
		check_orbit(time, delta)
		check_environment(time)
	clouds_front.rotation.y += 0.02 * delta
	clouds_back.rotation.y += 0.01 * delta

func check_orbit(time, delta):
	var day_percentage = float(time) / full_cycle
	var camera_pos = GlobalManager.camera.camera_lens.global_translation
	if camera_pos != null:
		sky.global_translation = Vector3(camera_pos.x, camera_pos.y - 32, camera_pos.z)
		clouds.global_translation = Vector3(camera_pos.x, camera_pos.y + 16, camera_pos.z)
		clouds_front.global_translation = Vector3(camera_pos.x, camera_pos.y + 2, camera_pos.z)
		clouds_back.global_translation = Vector3(camera_pos.x, camera_pos.y + 2, camera_pos.z)
		orbital.global_translation = camera_pos
	orbital.rotation.x = lerp_angle(orbital.rotation.x, (-180 * PI / 180) + (day_percentage * (2 * PI)), 0.01)
	if time in range (360, 1080):
		light.rotation.x = lerp_angle(light.rotation.x, (180 * PI / 180) + (day_percentage * 4), 0.5 * delta)
	elif time >= night:
		light.rotation.x = lerp_angle(light.rotation.x, (360 * PI / 180) + (day_percentage * 4), 0.5 * delta)

func check_environment(time):
	if time in range(dawn, day):
		change_environment(dawn_ambient_color, dawn_light_color, dawn_sky_color, dawn_fog_color, 512)
	elif time in range(day, dusk):
		change_environment(day_ambient_color, day_light_color, day_sky_color, day_fog_color, 2560)
	elif time in range(dusk, night):
		change_environment(dusk_ambient_color, dusk_light_color, dusk_sky_color, dusk_fog_color, 2048)
	else:
		change_environment(night_ambient_color, night_light_color, night_sky_color, night_fog_color, 512)

func change_environment(new_ambient_color, new_light_color, new_sky_color, new_fog_color, new_fog_depth):
	var ambient_color = environment.environment.ambient_light_color
	var light_color = light.light_color
	var sky_color = environment.environment.background_color
	var fog_color = environment.environment.fog_color
	var fog_depth_end = environment.environment.fog_depth_end
	#var sky_color = sky.get_surface_material(0).get_shader_param("texture_albedo").get_gradient()
	$Tween.interpolate_property(environment.environment, "ambient_light_color", ambient_color, new_ambient_color, transition_speed, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.interpolate_property(light, "light_color", light_color, new_light_color, transition_speed, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.interpolate_property(environment.environment, "background_color", sky_color, new_sky_color, transition_speed, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.interpolate_property(environment.environment, "fog_color", fog_color, new_fog_color, transition_speed, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.interpolate_property(environment.environment, "fog_depth_end", fog_depth_end, new_fog_depth, transition_speed, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	#print(sky_color.get_color(0))
	#sky_color.set_color(0, lerp(sky_color.get_color(0), sky_color, transition_speed))
	#sky_color.set_color(1, lerp(sky_color.get_color(1), sky_color, transition_speed))
	#$Tween.interpolate_property(sky_color.gradient, "colors", sky_color, new_sky_color, transition_speed, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	#$Tween.interpolate_property(sky_color.gradient, "colors", sky_color, new_sky_color, transition_speed, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()

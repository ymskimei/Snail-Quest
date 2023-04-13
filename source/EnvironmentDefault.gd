extends Spatial

export var dawn_sky_color = Color("B8CFD9")
export var dawn_ambient_color = Color("F0C874")
export var dawn_light_color = Color("9E9E9E")
export var dawn_fog_color = Color("9FAB8B")

export var day_sky_color = Color("ADD9FF")
export var day_ambient_color = Color("FFFFFF")
export var day_light_color = Color("919181")
export var day_fog_color = Color("899C99")

export var dusk_sky_color = Color("FAACB8")
export var dusk_ambient_color = Color("873232")
export var dusk_light_color = Color("C79D43")
export var dusk_fog_color = Color("CC9866")

export var night_sky_color = Color("45396C")
export var night_ambient_color = Color("433A51")
export var night_light_color = Color("5D677A")
export var night_fog_color = Color("4E5689")

export var full_cycle = 1440
export var half_cycle = 720
export var dawn = 360
export var day = 480
export var dusk = 960
export var night = 1080	
export var transition_speed = 15

func _physics_process(_delta):
	if GlobalManager.game_time != null:
		var time = GlobalManager.game_time.get_raw_time()
		check_orbit(time)
		check_environment(time)

func check_orbit(time):
	var day_percentage = float(time) / full_cycle
	$"%Orbital".global_translation = GlobalManager.camera.global_translation
	$"%Orbital".rotation.x = lerp_angle($"%Orbital".rotation.x, (-180 * PI / 180) + (day_percentage * (2 * PI)), 0.01)
	if time in range (360, 1080):
		$"%DirectionalLight".rotation.x = lerp_angle($"%DirectionalLight".rotation.x, (180 * PI / 180) + (day_percentage * 4), 1)
	elif time >= night:
		$"%DirectionalLight".rotation.x = lerp_angle($"%DirectionalLight".rotation.x, (360 * PI / 180) + (day_percentage * 4), 1)

func check_environment(time):
	if time in range(dawn, day):
		change_environment(dawn_ambient_color, dawn_light_color, dawn_sky_color, dawn_fog_color)
	elif time in range(day, dusk):
		change_environment(day_ambient_color, day_light_color, day_sky_color, day_fog_color)
	elif time in range(dusk, night):
		change_environment(dusk_ambient_color, dusk_light_color, dusk_sky_color, dusk_fog_color)
	else:
		change_environment(night_ambient_color, night_light_color, night_sky_color, night_fog_color)

func change_environment(new_ambient_color, new_light_color, new_sky_color, new_fog_color):
	var ambient_color = $WorldEnvironment.environment.ambient_light_color
	var light_color = $"%DirectionalLight".light_color
	var sky_color = $WorldEnvironment.environment.background_color
	var fog_color = $WorldEnvironment.environment.fog_color
	$Tween.interpolate_property($WorldEnvironment.environment, "ambient_light_color", ambient_color, new_ambient_color, transition_speed, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($"%DirectionalLight", "light_color", light_color, new_light_color, transition_speed, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($WorldEnvironment.environment, "background_color", sky_color, new_sky_color, transition_speed, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($WorldEnvironment.environment, "fog_color", fog_color, new_fog_color, transition_speed, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()

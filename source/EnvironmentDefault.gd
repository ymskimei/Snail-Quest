extends Spatial

export var dawn_sky_color = Color("D0ECE9")
export var dawn_ambient_color = Color("FFFFFF")
export var dawn_light_color = Color("9E9E9E")

export var day_sky_color = Color("8AD6FF")
export var day_ambient_color = Color("FFFFFF")
export var day_light_color = Color("B2B2B2")

export var dusk_sky_color = Color("FAACB8")
export var dusk_ambient_color = Color("873232")
export var dusk_light_color = Color("BB9950")

export var night_sky_color = Color("45396C")
export var night_ambient_color = Color("433A51")
export var night_light_color = Color("759CAF")

export var full_cycle = 1440
export var half_cycle = 720
export var dawn = 360
export var day = 480
export var dusk = 960
export var night = 1140
export var transition_speed = 60.0

func _ready():
	GameTime.game_time = half_cycle #temporary to start the game in day mode
	start_environment()
	start_orbit()
	
func _physics_process(_delta):
	check_environment()
	check_orbit()

func start_environment():
	var time = GameTime.get_raw_time()
	if time in range(dawn, day):
		set_environment(dawn_ambient_color, dawn_light_color, dawn_sky_color)
	elif time in range(day, dusk):
		set_environment(day_ambient_color, day_light_color, day_sky_color)
	elif time in range(dusk, night):
		set_environment(dusk_ambient_color, dusk_light_color, dusk_sky_color)
	else:
		set_environment(night_ambient_color, night_light_color, night_sky_color)

func check_environment():
	var time = GameTime.get_raw_time()
	var day_percentage = float(GameTime.get_raw_time()) / full_cycle
	if time in range(dawn, day):
		change_environment(dawn_ambient_color, dawn_light_color, dawn_sky_color)
	elif time in range(day, dusk):
		change_environment(day_ambient_color, day_light_color, day_sky_color)
	elif time in range(dusk, night):
		change_environment(dusk_ambient_color, dusk_light_color, dusk_sky_color)
	else:
		change_environment(night_ambient_color, night_light_color, night_sky_color)

func set_environment(start_ambient_color, start_light_color, start_sky_color):
	$WorldEnvironment.environment.ambient_light_color = start_ambient_color
	$"%DirectionalLight".light_color = start_light_color
	$WorldEnvironment.environment.background_color = start_sky_color

func change_environment(new_ambient_color, new_light_color, new_sky_color):
	var ambient_color = $WorldEnvironment.environment.ambient_light_color
	var light_color = $"%DirectionalLight".light_color
	var sky_color = $WorldEnvironment.environment.background_color
	$Tween.interpolate_property($WorldEnvironment.environment, "ambient_light_color", ambient_color, new_ambient_color, transition_speed, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($"%DirectionalLight", "light_color", light_color, new_light_color, transition_speed, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($WorldEnvironment.environment, "background_color", sky_color, new_sky_color, transition_speed, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()

func start_orbit():
	var time = GameTime.get_raw_time()
	var day_percentage = float(GameTime.get_raw_time()) / full_cycle
	if time in range (360, 1080):
		$"%DirectionalLight".rotation.x = (-180 * PI / 180) + ((day_percentage / 2) * (2 * PI))
	elif time >= night:
		$"%DirectionalLight".rotation.x = (-90 * PI / 180) + ((day_percentage / 2) * (2 * PI))

func check_orbit():
	var time = GameTime.get_raw_time()
	var day_percentage = float(GameTime.get_raw_time()) / full_cycle
	$"%Orbital".rotation.x = (-180 * PI / 180) + (day_percentage * (2 * PI))
	if time in range (360, 1080):
		$Tween.interpolate_property($"%DirectionalLight", "rotation:x", $"%DirectionalLight".rotation.x, (-180 * PI / 180) + ((day_percentage / 2) * (2 * PI)), 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$Tween.start()
	elif time >= night:
		$Tween.interpolate_property($"%DirectionalLight", "rotation:x", $"%DirectionalLight".rotation.x, (-90 * PI / 180) + ((day_percentage / 2) * (2 * PI)), 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$Tween.start()

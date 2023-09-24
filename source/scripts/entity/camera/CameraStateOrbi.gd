extends CameraStateMain

export var follow_speed: float = 3.5
export var rotation_speed: int = 10
export var offset: Vector3 = Vector3(0, 0.5, 0)

export var lock_high_arm: float = 0.0
export var lock_high_lens: float = 0.3

export var lock_low_arm: float = -0.85
export var lock_low_lens: float = -0.025

export var lock_default_arm: float = -0.2
export var lock_default_lens: float = 0.075

export var fov: int = 30
export var arm: float = 9

var distance: float = 0
var input_spin: int = 0

var look_around: bool
var zoom_mode: bool
var can_exit_mode: bool

var spin_timer: Timer = Timer.new()
var look_timer: Timer = Timer.new()

func enter() -> void:
	print("Camera State: ORBIT")
	tween_cam_pan(lock_default_arm, lock_default_lens)
	tween_cam_reset()
	add_control_timers()
	zoom_mode = false
	look_around = false
	distance = 0

func unhandled_input(event) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotation = event.relative
		controller = false
	elif event is InputEventJoypadMotion:
		controller = true
	else:
		rotation = Vector2.ZERO

func physics_process(delta: float):
	if look_around:
		return State.LOOK
	if entity.cam_target is Player and entity.cam_target.targeting:
		return State.TARG
	if is_instance_valid(entity.cam_target):
		cam_tracking(delta)
		cam_panning(delta)
		cam_reset()
	else:
		return State.FREE
	if entity.targeting_vehicle:
		return State.VEHI
	return State.NULL

func cam_tracking(delta: float) -> void:
	rotation.x = Input.get_action_strength("cam_left") - Input.get_action_strength("cam_right")
	rotation.x += (-Input.get_action_strength("joy_right") + Input.get_action_strength("joy_left")) / 3
	velocity = velocity.linear_interpolate(rotation * sensitivity / 5, delta * rotation_speed)
	entity.rotation.y += (deg2rad(velocity.x))
	entity.translation = lerp(entity.translation, entity.cam_target.translation + offset, follow_speed * delta)
	entity.spring_length = lerp(entity.spring_length, clamp(entity.spring_length + distance, 4, 30), 10 * delta)

func cam_panning(delta: float) -> void:
	var distance_to_target = entity.camera_lens.get_global_translation().distance_to(entity.cam_target.get_global_translation())
	if distance_to_target <= 1.5:
		tween_cam_pan(lock_low_arm, lock_low_lens)
	elif distance_to_target >= 2:
		if Input.is_action_just_pressed("cam_zoom"):
			look_timer.start()
		if Input.is_action_just_released("cam_zoom"):
			zoom_mode = true
		if !zoom_mode:
			if Input.is_action_pressed("cam_up"):
				tween_cam_pan(lock_high_arm, lock_high_lens)
			elif Input.is_action_pressed("cam_down"):
				tween_cam_pan(lock_low_arm, lock_low_lens)
			else:
				tween_cam_pan(lock_default_arm, lock_default_lens)
		else:
			cam_zooming(delta)

func cam_zooming(delta: float) -> void:
	if Input.is_action_pressed("cam_up"):
		distance -= 15 * delta
	elif Input.is_action_pressed("cam_down"):
		distance += 15 * delta
	else:
		distance = 0
	if Input.is_action_just_pressed("cam_zoom"):
		can_exit_mode = true
	if can_exit_mode and Input.is_action_just_released("cam_zoom"):
		can_exit_mode = false
		zoom_mode = false

func cam_reset() -> void:
	if Input.is_action_just_pressed("cam_left") or Input.is_action_just_pressed("cam_right") or Input.is_action_just_pressed("cam_up") or Input.is_action_just_pressed("cam_down"):
		input_spin += 1
		spin_timer.start()
		if input_spin >= 4:
			tween_cam_reset()

func add_control_timers() -> void:
	if !is_instance_valid(get_node_or_null("SpinTimer")):
		spin_timer.set_one_shot(true)
		spin_timer.set_wait_time(0.5)
		spin_timer.connect("timeout", self, "on_spin_timer")
		spin_timer.set_name("SpinTimer")
		add_child(spin_timer)
	if !is_instance_valid(get_node_or_null("LookTimer")):
		look_timer.set_one_shot(true)
		look_timer.set_wait_time(0.25)
		look_timer.connect("timeout", self, "on_look_timer")
		look_timer.set_name("LookTimer")
		add_child(look_timer)

func on_spin_timer() -> void:
	input_spin = 0

func on_look_timer() -> void:
	if Input.is_action_pressed("cam_zoom"):
		look_around = true

func tween_cam_zoom(dist: float) -> void:
	entity.anim_tween.interpolate_property(entity, "spring_length", entity.spring_length, entity.spring_length + dist, 0.4, Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
	entity.anim_tween.start()

func tween_cam_reset() -> void:
	entity.anim_tween.interpolate_property(entity.camera_lens, "fov", entity.camera_lens.fov, fov, 0.25, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	entity.anim_tween.interpolate_property(entity, "spring_length", entity.spring_length, arm, 0.4, Tween.TRANS_EXPO, Tween.EASE_OUT)
	entity.anim_tween.start()

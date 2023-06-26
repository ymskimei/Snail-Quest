extends CameraStateMain

export var follow_speed = 3.5
export var rotation_speed = 10
export var offset = Vector3(0, 0.8, 0)

export var lock_high_arm = 0.0
export var lock_high_lens = 0.3

export var lock_low_arm = -0.85
export var lock_low_lens = -0.025

export var lock_default_arm = -0.2
export var lock_default_lens = 0.075

export var zoom_normal = 40
export var distance_normal = 8.5

var distance = 0
var input_spin = 0

var look_around : bool
var zoom_mode : bool
var can_exit_mode : bool

var spin_timer = Timer.new()
var look_timer = Timer.new()

func enter() -> void:
	print("Camera State: ORBIT")
	tween_cam_pan(lock_default_arm, lock_default_lens)
	tween_cam_reset()
	add_control_timers()
	zoom_mode = false
	look_around = false
	distance = 0

func unhandled_input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotation = event.relative
		controller = false
	elif event is InputEventJoypadMotion:
		controller = true
	else:
		rotation = Vector2.ZERO

func physics_process(delta):
	cam_tracking(delta)
	cam_panning(delta)
	cam_reset()
	if look_around:
		return State.LOOK
	if entity.player.targeting:
		return State.TARG
	return State.NULL

func cam_tracking(delta):
	rotation.x = Input.get_action_strength("cam_left") - Input.get_action_strength("cam_right")
	if entity.player.can_move:
		rotation.x += (-Input.get_action_strength("joy_right") + Input.get_action_strength("joy_left")) / 3
	velocity = velocity.linear_interpolate(rotation * sensitivity / 3, delta * rotation_speed)
	entity.rotation.y += (deg2rad(velocity.x))
	entity.translation = lerp(entity.translation, entity.player.translation + offset, follow_speed * delta)
	entity.spring_length = lerp(entity.spring_length, clamp(entity.spring_length + distance, 4, 30), 10 * delta)

func cam_panning(delta):
	var distance_to_player = entity.camera_lens.get_global_translation().distance_to(entity.player.get_global_translation())
	if distance_to_player <= 1.5:
		tween_cam_pan(lock_low_arm, lock_low_lens)
	elif distance_to_player >= 2:
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

func cam_zooming(delta):
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

func cam_reset():
	if Input.is_action_just_pressed("cam_left") or Input.is_action_just_pressed("cam_right") or Input.is_action_just_pressed("cam_up") or Input.is_action_just_pressed("cam_down"):
		input_spin += 1
		spin_timer.start()
		if input_spin >= 4:
			tween_cam_reset()

func add_control_timers():
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

func on_spin_timer():
	input_spin = 0

func on_look_timer():
	if Input.is_action_pressed("cam_zoom"):
		look_around = true

func tween_cam_zoom(dist):
	entity.anim_tween.interpolate_property(entity, "spring_length", entity.spring_length, entity.spring_length + dist, 0.4, Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
	entity.anim_tween.start()

func tween_cam_reset():
	entity.anim_tween.interpolate_property(entity.camera_lens, "fov", entity.camera_lens.fov, zoom_normal, 0.25, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	entity.anim_tween.interpolate_property(entity, "spring_length", entity.spring_length, distance_normal, 0.4, Tween.TRANS_EXPO, Tween.EASE_OUT)
	entity.anim_tween.start()

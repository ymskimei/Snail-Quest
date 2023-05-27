extends CameraStateMain

export var follow_speed = 3.5
export var rotation_speed = 10
export var offset = Vector3(0, 0.8, 0)
export var lock_high_arm = 0.05
export var lock_high_lens = 0.15
export var lock_low_arm = -0.85
export var lock_low_lens = -0.025
export var lock_default_arm = -0.3
export var lock_default_lens = 0.075
export var zoom_normal = 40
export var zoom_far = 50
export var distance_normal = 8.5
var distance = 0
var input_spin = 0
var look_around : bool

func enter() -> void:
	print("Camera State: ORBIT")
	tween_cam_pan(lock_default_arm, lock_default_lens)
	cam_reset()
	zoomed_out = false
	look_around = false

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
	cam_panning()
	cam_zooming(delta)
	if Input.is_action_pressed("cam_zoom"):
		if Input.is_action_pressed("cam_left"):
			return State.LOOK
		if Input.is_action_pressed("cam_right"):
			return State.ISOM
	if look_around:
		return State.LOOK
	if entity.player.targeting:
		return State.TARG
	return State.NULL

func cam_tracking(delta):
	rotation.x = Input.get_action_strength("cam_left") - Input.get_action_strength("cam_right")
	if entity.player.can_move:
		rotation.x += -Input.get_action_strength("joy_right") / 3 + Input.get_action_strength("joy_left") / 3
	velocity = velocity.linear_interpolate(rotation * sensitivity / 3, delta * rotation_speed)
	entity.rotation.y += (deg2rad(velocity.x))
	entity.translation = lerp(entity.translation, entity.player.translation + offset, follow_speed * delta)
	entity.spring_length = lerp(entity.spring_length, entity.spring_length + distance, 0.5 * delta)

func cam_panning():
	var distance_to_player = entity.camera_lens.get_global_translation().distance_to(entity.player.get_global_translation())
	if distance_to_player <= 1.5:
		tween_cam_pan(lock_low_arm, lock_low_lens)
	elif distance_to_player >= 2:
		if !Input.is_action_pressed("cam_zoom"):
			if Input.is_action_pressed("cam_up"):
				tween_cam_pan(lock_high_arm, lock_high_lens)
			elif Input.is_action_pressed("cam_down"):
				tween_cam_pan(lock_low_arm, lock_low_lens)
			else:
				tween_cam_pan(lock_default_arm, lock_default_lens)

func cam_zooming(delta):
	if Input.is_action_pressed("cam_zoom"):
		if Input.is_action_pressed("cam_up"):
			distance += 3
		elif Input.is_action_pressed("cam_down"):
			distance -= 3
		else:
			spin_timer()
	else:
		distance = 0

	if Input.is_action_just_pressed("cam_left") or Input.is_action_just_pressed("cam_right") or Input.is_action_just_pressed("cam_up") or Input.is_action_just_pressed("cam_down"):
		input_spin += 1
		spin_timer()
		if input_spin >= 4:
			cam_reset()

func spin_timer():
	var timer = Timer.new()
	timer.set_one_shot(true)
	timer.set_wait_time(0.5)
	timer.connect("timeout", self, "on_input_timer")
	add_child(timer)
	timer.start()

func on_input_timer():
	input_spin = 0
	if Input.is_action_pressed("cam_zoom") and !(Input.is_action_pressed("cam_up") or Input.is_action_pressed("cam_down")):
		look_around = true

func tween_cam_zoom(distance):
	entity.anim_tween.interpolate_property(entity, "spring_length", entity.spring_length, entity.spring_length + distance, 0.4, Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
	entity.anim_tween.start()

func cam_reset():
	entity.anim_tween.interpolate_property(entity.camera_lens, "fov", entity.camera_lens.fov, zoom_normal, 0.25, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	entity.anim_tween.interpolate_property(entity, "spring_length", entity.spring_length, distance_normal, 0.4, Tween.TRANS_EXPO, Tween.EASE_OUT)
	entity.anim_tween.start()

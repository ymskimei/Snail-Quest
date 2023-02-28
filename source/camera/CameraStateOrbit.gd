extends CameraStateMain

export var follow_speed = 3.5
export var rotation_speed = 10
export var offset = Vector3(0, 1, 0)
export var lock_high_lens = 0.1
export var lock_high = 0.3
export var lock_low_lens = -0.7
export var lock_low = -0.2
export var lock_default_lens = -0.3
export var lock_default = 0.1
export var zoom_normal = 60
export var zoom_far = 75
export var distance_normal = 5
export var distance_far = 6
var input_up = 0
var input_down = 0

func enter() -> void:
	print("Camera State: ORBIT")
	tween_cam_zoom(zoom_normal, distance_normal)
	tween_cam_pan(lock_default_lens, lock_default)

func unhandled_input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotation = event.relative
		controller_detected = false
	elif event is InputEventJoypadMotion:
		controller_detected = true
	else:
		rotation = Vector2.ZERO

func physics_process(delta):
	var rotation = Vector2.ZERO
	rotation.x = Input.get_action_raw_strength("cam_right") - Input.get_action_raw_strength("ui_right") / 3 - Input.get_action_raw_strength("cam_left") + Input.get_action_raw_strength("ui_left") / 3
	velocity = velocity.linear_interpolate(rotation * sensitivity / 3, delta * rotation_speed)
	camera.rotation.y += (deg2rad(velocity.x))
	camera.translation = lerp(camera.translation, camera.camera_target.translation + offset, follow_speed * delta)
	apply_cam_pan()
	apply_cam_zoom()
	if Input.is_action_just_pressed("cam_lock"):
		return State.TARGET
	return State.NULL

func apply_cam_pan():
	if Input.is_action_just_pressed("cam_up"):
		double_click()
		input_up += 1
		tween_cam_pan(lock_high_lens, lock_high)
	if Input.is_action_just_pressed("cam_down"):
		double_click()
		input_down += 1
		tween_cam_pan(lock_low_lens, lock_low)
	if (Input.is_action_just_released("cam_up") and input_up < 2) or (Input.is_action_just_released("cam_down") and input_down < 2):
		tween_cam_pan(lock_default_lens, lock_default)

func tween_cam_pan(lens, arm):
	camera.anim_tween.interpolate_property(camera, "rotation:x", camera.rotation.x, lens, 0.15, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	camera.anim_tween.interpolate_property(camera.camera_lens, "rotation:x", camera.camera_lens.rotation.x, arm, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	camera.anim_tween.start()	

func double_click():
	var timer = Timer.new()
	timer.set_one_shot(true)
	timer.set_wait_time(0.5)
	timer.connect("timeout", self, "on_input_timer")
	add_child(timer)
	timer.start()

func on_input_timer():
	input_up = 0
	input_down = 0

func apply_cam_zoom():
	if Input.is_action_just_pressed("cam_zoom"):
		if camera.camera_lens.fov == zoom_far:
			tween_cam_zoom(zoom_normal, distance_normal)
			camera.audio_player.sfx_cam_zoom_normal.play()
			print("Camera view altered: Normal")
		else:
			tween_cam_zoom(zoom_far, distance_far)
			camera.audio_player.sfx_cam_zoom_far.play()
			print("Camera view altered: Far")

func tween_cam_zoom(zoom, distance):
	camera.anim_tween.interpolate_property(camera.camera_lens, "fov", camera.camera_lens.fov, zoom, 0.3, Tween.TRANS_BACK, Tween.EASE_IN_OUT)
	camera.anim_tween.interpolate_property(camera, "spring_length", camera.spring_length, distance, 0.4, Tween.TRANS_BACK, Tween.EASE_IN_OUT)
	camera.anim_tween.start()

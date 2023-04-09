extends CameraStateMain

export var follow_speed = 3.5
export var rotation_speed = 10
export var offset = Vector3(0, 1, 0)
export var lock_high_arm = 0.1
export var lock_high_lens = 0.3
export var lock_low_arm = -0.7
export var lock_low_lens = -0.05
export var lock_default_arm = -0.3
export var lock_default_lens = 0.1
export var zoom_normal = 60
export var zoom_far = 75
export var distance_normal = 5
export var distance_far = 6

var input_up = 0
var input_down = 0

func enter() -> void:
	print("Camera State: ORBIT")
	tween_cam_pan(lock_default_arm, lock_default_lens)
	tween_cam_zoom(zoom_normal, distance_normal)
	zoomed_out = false
	entity.anim_tween.interpolate_property(entity.camera_lens, "fov", entity.camera_lens.fov, zoom_normal, 0.25, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	entity.anim_tween.interpolate_property(entity, "spring_length", entity.spring_length, distance_normal, 0.4, Tween.TRANS_EXPO, Tween.EASE_OUT)
	entity.anim_tween.start()

func unhandled_input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotation = event.relative
		controller = false
	elif event is InputEventJoypadMotion:
		controller = true
	else:
		rotation = Vector2.ZERO

func physics_process(delta):
	rotation.x = Input.get_action_strength("cam_right") - Input.get_action_strength("cam_left")
	if entity.player.can_move:
		rotation.x += -Input.get_action_strength("ui_right") / 3 + Input.get_action_strength("ui_left") / 3
	#rotation.x = Input.get_action_strength("cam_right") - Input.get_action_strength("ui_right") / 3 - Input.get_action_strength("cam_left") + Input.get_action_strength("ui_left") / 3
	velocity = velocity.linear_interpolate(rotation * sensitivity / 3, delta * rotation_speed)
	entity.rotation.y += (deg2rad(velocity.x))
	entity.translation = lerp(entity.translation, entity.player.translation + offset, follow_speed * delta)
	if Input.is_action_just_pressed("cam_up"):
		input_up += 1
		double_click()
		if input_up >= 2:
			return State.LOOK
		else:
			tween_cam_pan(lock_high_arm, lock_high_lens)
	if Input.is_action_just_pressed("cam_down"):
		input_down += 1
		double_click()
		if input_down >= 2:
			return State.ISOM
		else:
			tween_cam_pan(lock_low_arm, lock_low_lens)
	if Input.is_action_just_released("cam_up") and input_up < 2 or Input.is_action_just_released("cam_down") and input_down < 2:
		tween_cam_pan(lock_default_arm, lock_default_lens)
	if entity.player.targeting:
		return State.TARG
	apply_cam_zoom()
	return State.NULL

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
		if zoomed_out:
			tween_cam_zoom(zoom_normal, distance_normal)
			AudioPlayer.play_sfx(AudioPlayer.sfx_cam_zoom_normal)
			print("Camera view altered: Normal")
			zoomed_out = false
		else:
			tween_cam_zoom(zoom_far, distance_far)
			AudioPlayer.play_sfx(AudioPlayer.sfx_cam_zoom_far)
			print("Camera view altered: Far")
			zoomed_out = true

func tween_cam_zoom(zoom, distance):
	entity.anim_tween.interpolate_property(entity.camera_lens, "fov", entity.camera_lens.fov, zoom, 0.3, Tween.TRANS_BACK, Tween.EASE_IN_OUT)
	entity.anim_tween.interpolate_property(entity, "spring_length", entity.spring_length, distance, 0.4, Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
	entity.anim_tween.start()

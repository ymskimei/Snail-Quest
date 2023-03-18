class_name CameraStateIsom
extends CameraStateMain

export var rotation_speed = 10
export var offset = Vector3(0, 1, 0)
export var follow_speed = 3.5
export var lock_iso_arm = -0.5
export var lock_iso_lens = 0.0
export var zoom_iso = 15
export var distance_iso = 40
var rotation_timer_right = Timer.new()
var rotation_timer_left = Timer.new()
var cam_overhead : bool

func enter() -> void:
	print("Camera State: ISOMETRIC")
	tween_cam_pan(lock_iso_arm, lock_iso_lens)
	tween_cam_zoom(zoom_iso, distance_iso)
	entity.anim_tween.interpolate_property(entity, "rotation:y", entity.rotation.y, stepify(entity.rotation.y, deg2rad(45)), 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	entity.anim_tween.start()
	rotation_timer_right.set_wait_time(0.5)
	rotation_timer_right.connect("timeout", self, "on_timeout_right")
	add_child(rotation_timer_right)
	rotation_timer_left.set_wait_time(0.5)
	rotation_timer_left.connect("timeout", self, "on_timeout_left")
	add_child(rotation_timer_left)

func physics_process(delta):
	entity.translation = lerp(entity.translation, entity.player.translation + offset, follow_speed * delta)
	if Input.is_action_just_pressed("cam_right"):
		tween_isometric(45)
		rotation_timer_right.start()
	if Input.is_action_just_released("cam_right"):
		rotation_timer_right.stop()
	if Input.is_action_just_pressed("cam_left"):
		tween_isometric(-45)
		rotation_timer_left.start()
	if Input.is_action_just_released("cam_left"):
		rotation_timer_left.stop()
	if Input.is_action_just_pressed("cam_up"):
		cam_overhead = true
		tween_overhead(-90)
	if Input.is_action_just_pressed("cam_down"):
		if cam_overhead:
			tween_cam_pan(lock_iso_arm, entity.camera_lens.rotation.x)
			cam_overhead = false
		else:
			rotation_timer_right.stop()
			rotation_timer_left.stop()
			return State.ORBI
	return State.NULL

func unhandled_input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotation = event.relative
		controller = false
	elif event is InputEventJoypadMotion:
		controller = true
	else:
		rotation = Vector2.ZERO

func on_timeout_right():
	tween_isometric(45)

func on_timeout_left():
	tween_isometric(-45)

func tween_isometric(direction):
	entity.anim_tween.interpolate_property(entity, "rotation:y", entity.rotation.y, entity.rotation.y + deg2rad(direction), 0.3, Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
	entity.anim_tween.start()

func tween_overhead(direction):
	entity.anim_tween.interpolate_property(entity, "rotation:x", entity.rotation.x, deg2rad(direction), 0.3, Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
	entity.anim_tween.start()

func tween_cam_zoom(zoom, distance):
	entity.anim_tween.interpolate_property(entity.camera_lens, "fov", entity.camera_lens.fov, zoom, 0.3, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	entity.anim_tween.interpolate_property(entity, "spring_length", entity.spring_length, distance, 0.5, Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
	entity.anim_tween.start()

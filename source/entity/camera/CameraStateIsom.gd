class_name CameraStateIsom
extends CameraStateMain

export var rotation_speed = 10
export var offset = Vector3(0, 1, 0)
export var follow_speed = 3.5
export var lock_iso_arm = -0.5
export var lock_iso_lens = 0.0
export var zoom_iso_far = 15
export var distance_iso_far = 50
export var zoom_iso_normal = 15
export var distance_iso_normal = 30

var rotation_timer_right = Timer.new()
var rotation_timer_left = Timer.new()

var cam_overhead : bool
var previous_sound : bool

func enter() -> void:
	print("Camera State: ISOMETRIC")
	AudioPlayer.play_sfx(AudioPlayer.sfx_cam_perspective)
	tween_cam_pan(lock_iso_arm, lock_iso_lens)
	tween_cam_zoom(zoom_iso_normal, distance_iso_normal)
	zoomed_out = false
	entity.anim_tween.interpolate_property(entity, "rotation:y", entity.rotation.y, stepify(entity.rotation.y, deg2rad(45)), 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	entity.anim_tween.start()
	entity.anim_wobble.play("Wobble")
	rotation_timer_right.set_wait_time(0.5)
	rotation_timer_right.connect("timeout", self, "on_timeout_right")
	add_child(rotation_timer_right)
	rotation_timer_left.set_wait_time(0.5)
	rotation_timer_left.connect("timeout", self, "on_timeout_left")
	add_child(rotation_timer_left)

func physics_process(delta: float) -> int:
	if entity.lock_to_point == true:
		return State.LOCK
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
	if Input.is_action_just_pressed("cam_right") or Input.is_action_just_pressed("cam_left"):
		rotation_sound()
	if Input.is_action_just_pressed("cam_up"):
		AudioPlayer.play_sfx(AudioPlayer.sfx_cam_iso_up)
		tween_overhead(-90)
		cam_overhead = true
	if Input.is_action_just_pressed("cam_down"):
		if cam_overhead:
			AudioPlayer.play_sfx(AudioPlayer.sfx_cam_iso_down)
			tween_cam_pan(lock_iso_arm, entity.camera_lens.rotation.x)
			cam_overhead = false
		else:
			rotation_timer_right.stop()
			rotation_timer_left.stop()
			AudioPlayer.play_sfx(AudioPlayer.sfx_cam_perspective)
			return State.ORBI
	if entity.player.targeting:
		return State.TARG
	apply_cam_zoom()
	return State.NULL

func on_timeout_right():
	tween_isometric(45)
	rotation_sound()
	
func on_timeout_left():
	tween_isometric(-45)
	rotation_sound()

func rotation_sound():
	if previous_sound:
		AudioPlayer.play_sfx(AudioPlayer.sfx_cam_iso_rotate_0)
		previous_sound = false
	else:
		AudioPlayer.play_sfx(AudioPlayer.sfx_cam_iso_rotate_1)
		previous_sound = true

func apply_cam_zoom():
	if Input.is_action_just_pressed("cam_zoom"):
		if zoomed_out:
			tween_cam_zoom(zoom_iso_normal, distance_iso_normal)
			AudioPlayer.play_sfx(AudioPlayer.sfx_cam_zoom_normal)
			print("Camera view altered: Normal")
			zoomed_out = false
		else:
			tween_cam_zoom(zoom_iso_far, distance_iso_far)
			AudioPlayer.play_sfx(AudioPlayer.sfx_cam_zoom_far)
			print("Camera view altered: Far")
			zoomed_out = true

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

func exit() -> void:
	entity.anim_wobble.stop()

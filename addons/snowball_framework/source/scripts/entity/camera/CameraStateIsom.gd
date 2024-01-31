class_name CameraStateIsom
extends CameraStateMain

#Entire mode to be used later in screenshotting,
#not the game's camera movement

@export var rotation_speed: int = 10
@export var offset: Vector3 = Vector3(0, 1, 0)
@export var follow_speed: float = 3.5
@export var lock_iso_arm: float = -0.5
@export var lock_iso_lens: float = 0.0
@export var fov_iso_far: int = 15
@export var arm_iso_far: int = 50
@export var fov_iso_normal: int = 15
@export var arm_iso_normal: int = 30

var rotation_timer_right: Timer = Timer.new()
var rotation_timer_left: Timer = Timer.new()

var cam_overhead: bool
var previous_sound: bool

func enter() -> void:
	print("Camera3D State: ISOMETRIC")
	tween_cam_pan(lock_iso_arm, lock_iso_lens)
	tween_cam_zoom(fov_iso_normal, arm_iso_normal)
	add_rotation_timers()
	SB.audio.play_sfx(SB.audio.sfx_cam_perspective)
	entity.anim_tween.interpolate_value(entity, "rotation:y", snapped(entity.rotation.y, deg_to_rad(45)), 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	entity.anim_tween.play()
	entity.anim_wobble.play("Wobble")
	zoomed_out = false

func states_physics_process(delta: float) -> int:
	cam_movement(delta)
	if entity.cam_target.targeting:
		return State.TARG
	apply_cam_zoom()
	return State.NULL

func cam_movement(delta: float) -> void:
	entity.position = lerp(entity.position, entity.cam_target.position + offset, follow_speed * delta)
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
		if !cam_overhead:
			SB.audio.play_sfx(SB.audio.sfx_cam_iso_up)
			tween_overhead(-90)
			cam_overhead = true
	if Input.is_action_just_pressed("cam_down"):
		if cam_overhead:
			SB.audio.play_sfx(SB.audio.sfx_cam_iso_down)
			tween_cam_pan(lock_iso_arm, entity.camera_lens.rotation.x)
			cam_overhead = false

func add_rotation_timers() -> void:
	rotation_timer_right.set_wait_time(0.5)
	rotation_timer_right.connect("timeout", Callable(self, "on_timeout_right"))
	add_child(rotation_timer_right)
	rotation_timer_left.set_wait_time(0.5)
	rotation_timer_left.connect("timeout", Callable(self, "on_timeout_left"))
	add_child(rotation_timer_left)

func on_timeout_right() -> void:
	tween_isometric(45)
	rotation_sound()
	
func on_timeout_left() -> void:
	tween_isometric(-45)
	rotation_sound()

func rotation_sound() -> void:
	if previous_sound:
		SB.audio.play_sfx(SB.audio.sfx_cam_iso_rotate_0)
		previous_sound = false
	else:
		SB.audio.play_sfx(SB.audio.sfx_cam_iso_rotate_1)
		previous_sound = true

func apply_cam_zoom() -> void:
	if Input.is_action_just_pressed("cam_zoom"):
		if zoomed_out:
			tween_cam_zoom(fov_iso_normal, arm_iso_normal)
			SB.audio.play_sfx(SB.audio.sfx_cam_zoom_normal)
			print("Camera3D view altered: Normal")
			zoomed_out = false
		else:
			tween_cam_zoom(fov_iso_far, arm_iso_far)
			SB.audio.play_sfx(SB.audio.sfx_cam_zoom_far)
			print("Camera3D view altered: Far")
			zoomed_out = true

func tween_isometric(direction: int) -> void:
	entity.anim_tween.interpolate_value(entity, "rotation:y", entity.rotation.y + deg_to_rad(direction), 0.3, Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
	entity.anim_tween.play()

func tween_overhead(direction: int) -> void:
	entity.anim_tween.interpolate_value(entity, "rotation:x", deg_to_rad(direction), 0.3, Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
	entity.anim_tween.play()

func tween_cam_zoom(zoom: int, distance: float) -> void:
	entity.anim_tween.interpolate_value(entity.camera_lens, "fov", zoom, 0.3, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	entity.anim_tween.interpolate_value(entity, "arm_length", distance, 0.5, Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
	entity.anim_tween.play()

func exit() -> void:
	entity.anim_wobble.stop()

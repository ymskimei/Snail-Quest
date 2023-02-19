extends SpringArm

onready var camera_lens = $CameraLens
onready var anim_cam = $CameraLens/Animation/AnimationCam
onready var audio_player = $WorldAudioPlayer
onready var default_target = $"/root/Game/Player"
onready var camera_target = $"/root/Game/Player"

export var sensitivity_mouse = 2
export var sensitivity_stick = 5

export var cam_lens_lock_top = 0.2
export var cam_lock_top = 0.2
export var cam_lens_lock_low = -0.7
export var cam_lock_low = -0.2
export var cam_lens_lock_default = -0.3
export var cam_lock_default = 0.1

export var cam_zoom_normal = 60
export var cam_distance_normal = 4
export var cam_zoom_far = 80
export var cam_distance_far = 5

export var cam_smoothness = 10
export var cam_speed = 3
export var cam_offset = Vector3(0, 1, 0)

var cam_rotation: Vector2
var cam_velocity: Vector2
var controller_detected = false

func _ready():
	pass

func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		cam_rotation = event.relative
		controller_detected = false
	elif event is InputEventJoypadMotion:
		controller_detected = true
	else:
		cam_rotation = Vector2.ZERO

func _physics_process(delta):
	if camera_target != null:
		var cam_rotation = Vector2.ZERO
		cam_rotation.x = Input.get_action_strength("cam_right") - Input.get_action_strength("ui_right") / 2 - Input.get_action_strength("cam_left") + Input.get_action_strength("ui_left") / 2
		if controller_detected:
			cam_velocity = cam_velocity.linear_interpolate(cam_rotation * sensitivity_stick / 1.5, delta * cam_smoothness / 2.5)
		else:
			cam_velocity = cam_velocity.linear_interpolate(cam_rotation * sensitivity_mouse / 5, delta * cam_smoothness)
#		if Input.is_action_just_pressed("cam_reset"):
#			print("Camera direction reset")
		rotation.y += (deg2rad(cam_velocity.x))
		translation = lerp(translation, camera_target.translation + cam_offset, cam_speed * delta)
		apply_cam_pan()
		apply_cam_zoom()
	apply_cam_target()

func apply_cam_target():
	if default_target != null:
		camera_target = default_target

func apply_cam_pan():
	if Input.is_action_pressed("cam_up"):
		tween_cam_pan(cam_lens_lock_top, cam_lock_top)
	elif Input.is_action_pressed("cam_down"):
		tween_cam_pan(cam_lens_lock_low, cam_lock_low)
	else:
		tween_cam_pan(cam_lens_lock_default, cam_lock_default)

func tween_cam_pan(lens, arm):
	anim_cam.interpolate_property(self, "rotation:x", self.rotation.x, lens, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	anim_cam.interpolate_property(camera_lens, "rotation:x", camera_lens.rotation.x, arm, 0.4, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	anim_cam.start()

func apply_cam_zoom():
	if Input.is_action_just_pressed("cam_zoom"):
		if camera_lens.fov == cam_zoom_far:
			tween_cam_zoom(cam_zoom_normal, cam_distance_normal)
			audio_player.sfx_cam_zoom_normal.play()
			print("Camera view altered: Normal")
		else:
			tween_cam_zoom(cam_zoom_far, cam_distance_far)
			audio_player.sfx_cam_zoom_far.play()
			print("Camera view altered: Far")

func tween_cam_zoom(zoom, distance):
	anim_cam.interpolate_property(self, "spring_length", spring_length, distance, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	anim_cam.interpolate_property(camera_lens, "fov", camera_lens.fov, zoom, 0.3, Tween.TRANS_BACK, Tween.EASE_IN_OUT)
	anim_cam.start()

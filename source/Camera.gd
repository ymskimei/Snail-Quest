extends SpringArm

onready var camera_lens = $CameraLens
onready var anim_cam_zoom = $CameraLens/Animation/AnimationCamZoom
onready var audio_player = $WorldAudioPlayer
onready var default_target = $"/root/Game/Player"
onready var camera_target = $"/root/Game/Player"

export var sensitivity_mouse = 2
export var sensitivity_stick = 2

export var cam_lock_top = 90
export var cam_lock_low = 5
export var cam_smoothness = 15
export var cam_speed = 3
export var cam_height: Vector3

export var cam_zoom_close = 3
export var cam_zoom_normal = 5
export var cam_zoom_far = 8

var cam_input: Vector2
var cam_velocity: Vector2
var controller_detected = false

var shake_x
var shake_y
var shake_target_rot: Vector3
var shake_event_rot: Vector2
var shake_noise_rot: Vector3
var shake_count = 0

export var shake_amp = 10
export var shake_freq = 100

func _ready():
	shake_x = OpenSimplexNoise.new()
	shake_y = OpenSimplexNoise.new()
	shake_x.seed = 0
	shake_x.octaves = 1
	shake_y.seed = 1
	shake_y.octaves = 1

func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		cam_input = event.relative
		controller_detected = false
	elif event is InputEventJoypadMotion:
		controller_detected = true
	else:
		cam_input = Vector2.ZERO

func _physics_process(delta):
	apply_cam_target()
	var axis_vector = Vector2.ZERO
	axis_vector.x = Input.get_action_strength("cam_right") - Input.get_action_strength("cam_left")
	axis_vector.y = Input.get_action_strength("cam_down") - Input.get_action_strength("cam_up")
	cam_input = axis_vector
	if controller_detected:
		cam_velocity = cam_velocity.linear_interpolate(cam_input * sensitivity_stick * 1.5, delta * cam_smoothness / 2.5)
	else:
		cam_velocity = cam_velocity.linear_interpolate(cam_input * sensitivity_mouse / 5, delta * cam_smoothness)
	self.rotation.x += (deg2rad(cam_velocity.y))
	self.rotation.y += (deg2rad(cam_velocity.x))
	self.rotation.x = clamp(rotation.x, deg2rad(-cam_lock_top), deg2rad(cam_lock_low))
	if camera_target != null:
		self.translation = lerp(self.translation, camera_target.translation + cam_height, cam_speed * delta)
#		if camera_target.velocity == Vector3.ZERO:
#			shake_count += delta * shake_freq
#			shake_noise_rot.x = shake_x.get_noise_1d(shake_count) + shake_amp
#			shake_noise_rot.y = shake_y.get_noise_1d(shake_count) + shake_amp
#			shake_target_rot.x += shake_event_rot.x
#			shake_target_rot.y += shake_event_rot.y
#			shake_event_rot = Vector2(0, 0)
#			self.rotation_degrees = lerp(self.rotation_degrees, self.rotation_degrees + shake_target_rot + shake_noise_rot, 3 * delta)
	apply_cam_zoom(delta)
 
func apply_cam_target():
	if default_target != null:
		camera_target = default_target

func tween_cam_zoom(targ):
	var cam_zoom = targ
	anim_cam_zoom.interpolate_property(self, "spring_length", self.spring_length, cam_zoom, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	anim_cam_zoom.start()
	pass

func apply_cam_zoom(delta):
		if Input.is_action_just_pressed("cam_zoom"):
			if self.spring_length == cam_zoom_far:
				tween_cam_zoom(cam_zoom_normal)
				camera_lens.fov = lerp(camera_lens.fov, 90, 2 * delta)
				audio_player.sfx_cam_zoom_normal.play()
				print("Camera distance altered: Normal")
			elif self.spring_length == cam_zoom_close:
				tween_cam_zoom(cam_zoom_far)
				audio_player.sfx_cam_zoom_far.play()
				print("Camera distance altered: Far")
			else:
				tween_cam_zoom(cam_zoom_close)
				audio_player.sfx_cam_zoom_close.play()
				print("Camera distance altered: Close")


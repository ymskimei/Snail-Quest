extends SpringArm

onready var anim_cam_zoom = $Camera/Animation/AnimationCamZoom
onready var audio_player = $Camera/WorldAudioPlayer

export var sensitivity_mouse = 2
export var sensitivity_stick = 2

export var cam_lock_top = 75
export var cam_lock_low = 15
export var cam_smoothness = 20
export var cam_zoom_close = 3
export var cam_zoom_normal = 5
export var cam_zoom_far = 8

var cam_input : Vector2
var cam_velocity: Vector2
var controller_detected = false

func _ready():
	pass

func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		cam_input = event.relative
		controller_detected = false
	elif event is InputEventJoypadMotion:
		controller_detected = true
		
func _physics_process(delta):
	var axis_vector = Vector2.ZERO
	axis_vector.x = Input.get_action_strength("cam_right") - Input.get_action_strength("cam_left")
	axis_vector.y = Input.get_action_strength("cam_down") - Input.get_action_strength("cam_up")
	if controller_detected:
		cam_input = axis_vector
		cam_velocity = cam_velocity.linear_interpolate(cam_input * sensitivity_stick * 1.5, delta * cam_smoothness / 2.5)
	else:
		cam_velocity = cam_velocity.linear_interpolate(cam_input * sensitivity_mouse / 6.5, delta * cam_smoothness)
	rotation.x += (deg2rad(cam_velocity.y))
	rotate_y(deg2rad(cam_velocity.x))
	rotation.x = clamp(rotation.x, deg2rad(-cam_lock_top), deg2rad(cam_lock_low))
	apply_cam_zoom()

func tween_cam_zoom(targ):
	var cam_zoom = targ
	anim_cam_zoom.interpolate_property(self, "spring_length", self.spring_length, cam_zoom, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	anim_cam_zoom.start()
	pass

func apply_cam_zoom():
		if Input.is_action_just_pressed("cam_zoom"):
			if self.spring_length == cam_zoom_far:
				tween_cam_zoom(cam_zoom_normal)
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

extends Camera

var cam_target = self

onready var default_target = get_node("..")
onready var audio_player = $WorldAudioPlayer
onready var anim_cam_zoom = $Animation/AnimationCamZoom

export var cam_zoom_close = 3
export var cam_zoom_normal = 5
export var cam_zoom_far = 8

func _ready():
	pass

func _physics_process(delta):
	apply_cam_target()
	apply_cam_zoom()

func apply_cam_target():
	if default_target != null:
		cam_target = default_target

func tween_cam_zoom(targ):
	var cam_zoom = targ
	anim_cam_zoom.interpolate_property(cam_target, "spring_length", cam_target.spring_length, cam_zoom, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	anim_cam_zoom.start()
	pass

func apply_cam_zoom():
	if cam_target != self:
		if Input.is_action_just_pressed("cam_zoom"):
			if cam_target.spring_length == cam_zoom_far:
				tween_cam_zoom(cam_zoom_normal)
				audio_player.sfx_cam_zoom_normal.play()
				print("Camera distance altered: Normal")
			elif cam_target.spring_length == cam_zoom_close:
				tween_cam_zoom(cam_zoom_far)
				audio_player.sfx_cam_zoom_far.play()
				print("Camera distance altered: Far")
			else:
				tween_cam_zoom(cam_zoom_close)
				audio_player.sfx_cam_zoom_close.play()
				print("Camera distance altered: Close")

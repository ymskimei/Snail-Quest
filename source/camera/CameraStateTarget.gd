extends CameraStateMain

onready var cam_target = $"/root/Game/Objects/Target"
export var follow_speed = 5.5
export var targeting_offset = Vector3(0, 1, 0)
export var targeting_rotation = -0.5
export var targeting_speed = 0.2
export var distance_targeting = 5
export var zoom_targeting = 50

func enter() -> void:
	camera.audio_player.sfx_cam_target_lock.play()
	camera.anim_player.play("BarsAppear")
	tween_cam_zoom()
	print("Camera State: LOCK")

func physics_process(delta):
	WorldMathHelper.slerp_look_at(camera, cam_target, targeting_speed)
	camera.translation = lerp(camera.translation, camera.camera_target.translation + targeting_offset, 5 * delta)
	camera.rotation.x = lerp(camera.rotation.x, targeting_rotation, follow_speed * delta)
	if Input.is_action_just_released("cam_lock"):
		return State.ORBIT
	return State.NULL

func tween_cam_zoom():
	camera.anim_tween.interpolate_property(camera.camera_lens, "fov", camera.camera_lens.fov, zoom_targeting, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	camera.anim_tween.interpolate_property(camera, "spring_length", camera.spring_length, distance_targeting, 0.3, Tween.TRANS_BACK, Tween.EASE_IN_OUT)
	camera.anim_tween.start()

func exit () -> void:
	camera.audio_player.sfx_cam_target_unlock.play()
	camera.anim_player.play("BarsDisappear")
	tween_cam_zoom()
	print("Camera State: TARGET")


extends CameraStateMain

export var follow_speed = 5.5
export var targeting_offset = Vector3(0, 1, 0)
export var targeting_rotation = -0.5
export var targeting_speed = 0.2
export var distance_targeting = 5
export var zoom_targeting = 50

func enter() -> void:
	print("Camera State: TARGET")
	AudioPlayer.play_sfx(AudioPlayer.sfx_cam_target_lock)
	entity.anim_bars.play("BarsAppear")
	tween_cam_zoom()

func physics_process(delta):
	if is_instance_valid(entity.player.target):
		MathHelper.slerp_look_at(entity, entity.player.target.global_transform.origin, targeting_speed)
	entity.rotation.x = lerp(entity.rotation.x, targeting_rotation, follow_speed * delta)
	entity.translation = lerp(entity.translation, entity.player.translation + targeting_offset, 5 * delta)
	if !entity.player.targeting:
		return State.ORBI
	return State.NULL

func tween_cam_zoom():
	entity.anim_tween.interpolate_property(entity.camera_lens, "fov", entity.camera_lens.fov, zoom_targeting, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	entity.anim_tween.interpolate_property(entity, "spring_length", entity.spring_length, distance_targeting, 0.3, Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
	entity.anim_tween.start()

func exit () -> void:
	AudioPlayer.play_sfx(AudioPlayer.sfx_cam_target_unlock)
	entity.anim_bars.play("BarsDisappear")
	tween_cam_zoom()

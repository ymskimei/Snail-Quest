extends CameraStateMain

export var follow_speed = 5.5
export var targeting_offset = Vector3(0, 1, 0)
export var targeting_rotation = -0.5
export var targeting_speed = 0.2

export var distance_targeting = 5
export var zoom_targeting = 50

var bars_active : bool

var bars_timer = Timer.new()

func enter() -> void:
	print("Camera State: TARGET")
	target_rot = entity.cam_target.rotation.y
	tween_cam_zoom()
	tween_cam_rotate(Tween.EASE_IN_OUT)
	add_bars_timer()
	bars_active = false
	rotation_complete = false

func physics_process(delta):
	if is_instance_valid(entity.cam_target.target):
		if entity.cam_target.target_found:
			MathHelper.slerp_look_at(entity, entity.cam_target.target.global_transform.origin, targeting_speed)
			entity.rotation.x = lerp(entity.rotation.x, targeting_rotation, follow_speed * delta)
			if !entity.cam_target.targeting:
				return State.ORBI
		else:
			entity.rotation.x = lerp(entity.rotation.x, -0.15, follow_speed * delta)
			if !entity.cam_target.targeting and rotation_complete:
				return State.ORBI
	entity.translation = lerp(entity.translation, entity.cam_target.translation + targeting_offset, 5 * delta)
	return State.NULL

func add_bars_timer():
	if !is_instance_valid(get_node_or_null("BarsTimer")):
		bars_timer.set_one_shot(true)
		bars_timer.set_wait_time(0.2)
		bars_timer.connect("timeout", self, "on_bars_timer")
		bars_timer.set_name("BarsTimer")
		add_child(bars_timer)
	bars_timer.start()

func on_bars_timer():
	if entity.cam_target.targeting:
		if entity.cam_target.target_found:
			AudioPlayer.play_sfx(AudioPlayer.sfx_cam_target_lock)
		else:
			AudioPlayer.play_sfx(AudioPlayer.sfx_cam_no_target_lock)
		entity.anim_bars.play("BarsAppear")
		bars_active = true
	else:
		AudioPlayer.play_sfx(AudioPlayer.sfx_cam_target_reset)

func tween_cam_zoom():
	entity.anim_tween.interpolate_property(entity.camera_lens, "fov", entity.camera_lens.fov, zoom_targeting, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	entity.anim_tween.interpolate_property(entity, "spring_length", entity.spring_length, distance_targeting, 0.3, Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
	entity.anim_tween.start()

func exit() -> void:
	if bars_active:
		if entity.cam_target.target_found:
			AudioPlayer.play_sfx(AudioPlayer.sfx_cam_target_unlock)
		else:
			AudioPlayer.play_sfx(AudioPlayer.sfx_cam_no_target_unlock)
		entity.anim_bars.play("BarsDisappear")
	tween_cam_zoom()
	rotation_complete = false

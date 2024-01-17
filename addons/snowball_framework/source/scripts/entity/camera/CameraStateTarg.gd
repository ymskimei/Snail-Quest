extends CameraStateMain

var offset: Vector3 = Vector3(0, 1, 0)

var track_speed: float = 5.5

var targeting_speed:float = 0.2
var targeting_rotation: float = -0.5

var distance_targeting: int = 5
var zoom_targeting: int = 50

var bars_active: bool

var bars_timer: Timer = Timer.new()

func enter() -> void:
	print("Camera State: TARGET")
	if entity.target is Entity:
		target_rot = entity.target.skeleton.rotation.y
	else:
		target_rot = entity.target.rotation.y
	_add_bars_timer()
	_tween_cam_zoom()
	tween_cam_rotate(Tween.EASE_IN_OUT)
	bars_active = false
	rotation_complete = false

func physics_process(delta: float) -> int:
	if is_instance_valid(entity.cam_target.target):
		if entity.target.target_found:
			SB.utility.slerp_look_at(entity, entity.target.target.global_transform.origin, targeting_speed)
			entity.rotation.x = lerp(entity.rotation.x, targeting_rotation, track_speed * delta)
			if !entity.target.targeting:
				return State.ORBI
		else:
			entity.rotation.x = lerp(entity.rotation.x, -0.15, track_speed * delta)
			if !entity.target.targeting and rotation_complete:
				return State.ORBI
	entity.translation = lerp(entity.translation, entity.target.translation + offset, 5 * delta)
	return State.NULL

func _add_bars_timer() -> void:
	if !is_instance_valid(get_node_or_null("BarsTimer")):
		bars_timer.set_one_shot(true)
		bars_timer.set_wait_time(0.2)
		bars_timer.connect("timeout", self, "on_bars_timer")
		bars_timer.set_name("BarsTimer")
		add_child(bars_timer)
	bars_timer.start()

func on_bars_timer() -> void:
	if entity.cam_target.targeting:
		if entity.cam_target.target_found:
			SB.utility.audio.play_sfx(RegistryAudio.cam_target_lock)
		else:
			SB.utility.audio.play_sfx(RegistryAudio.cam_no_target_lock)
		entity.anim_bars.play("BarsAppear")
		bars_active = true
	else:
		SB.utility.audio.play_sfx(RegistryAudio.cam_target_reset)

func _tween_cam_zoom() -> void:
	entity.anim_tween.interpolate_property(entity.lens, "fov", entity.lens.fov, zoom_targeting, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	entity.anim_tween.interpolate_property(entity, "spring_length", entity.spring_length, distance_targeting, 0.3, Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
	entity.anim_tween.start()

func exit() -> void:
	if bars_active:
		if entity.cam_target.target_found:
			SB.utility.audio.play_sfx(RegistryAudio.cam_target_unlock)
		else:
			SB.utility.audio.play_sfx(RegistryAudio.cam_no_target_unlock)
		entity.anim_bars.play("BarsDisappear")
	_tween_cam_zoom()
	rotation_complete = false

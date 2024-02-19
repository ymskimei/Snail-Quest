extends CameraStateMain

var offset: Vector3 = Vector3(0, -0.3, 0)

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
	tween_cam_rotate(Tween.EASE_IN_OUT)
	bars_active = false
	rotation_complete = false
	offset = Vector3(0, -0.3, 0)

func physics_process(delta: float) -> int:
	if entity.target.target:
		Utility.slerp_look_at(entity, entity.target.target.global_transform.origin, targeting_speed)
		entity.rotation.x = lerp(entity.rotation.x, targeting_rotation, track_speed * delta)
	else:
		entity.rotation.x = lerp(entity.rotation.x, -0.15, track_speed * delta)
		if !entity.target.targeting and rotation_complete:
			return State.ORBI
	entity.translation = lerp(entity.translation, entity.target.translation + offset, 5 * delta)
	entity.lens.translation = lerp(entity.lens.translation, _cam_shifting() * 20, 5 * delta)
	return State.NULL

func _cam_shifting() -> Vector3:
	var rotation_x = Input.get_action_strength(Device.stick_alt_right) - Input.get_action_strength(Device.stick_alt_left)
	var rotation_y = Input.get_action_strength(Device.stick_alt_up) - Input.get_action_strength(Device.stick_alt_down)
	if is_inverted():
			rotation_x = -rotation_x
			rotation_y = -rotation_y
	var modifier = Vector3(rotation_x, rotation_y, 0)
	return modifier

func _add_bars_timer() -> void:
	if !is_instance_valid(get_node_or_null("BarsTimer")):
		bars_timer.set_one_shot(true)
		bars_timer.set_wait_time(0.2)
		bars_timer.connect("timeout", self, "on_bars_timer")
		bars_timer.set_name("BarsTimer")
		add_child(bars_timer)
	bars_timer.start()

func on_bars_timer() -> void:
	if entity.target.targeting:
		offset = Vector3(0, 1, 0)
		_tween_cam_zoom()
		if entity.target.target_found:
			Audio.play_sfx(RegistryAudio.cam_target_lock)
		else:
			Audio.play_sfx(RegistryAudio.cam_no_target_lock)
		entity.anim_bars.play("BarsAppear")
		bars_active = true
	else:
		Audio.play_sfx(RegistryAudio.cam_target_reset)

func _tween_cam_zoom() -> void:
	entity.anim_tween.interpolate_property(entity.lens, "fov", entity.lens.fov, zoom_targeting, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	entity.anim_tween.interpolate_property(entity, "spring_length", entity.spring_length, distance_targeting, 0.3, Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
	entity.anim_tween.start()

func exit() -> void:
	if bars_active:
		if entity.target.target_found:
			Audio.play_sfx(RegistryAudio.cam_target_unlock)
		else:
			Audio.play_sfx(RegistryAudio.cam_no_target_unlock)
		entity.anim_bars.play("BarsDisappear")
	_tween_cam_zoom()
	rotation_complete = false

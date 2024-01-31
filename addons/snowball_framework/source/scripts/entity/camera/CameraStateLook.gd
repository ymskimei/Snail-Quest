extends CameraStateMain

var offset: Vector3 = Vector3(0, 0.1, 0)

var track_speed: int = 18
var rotation_speed: int = 10

func enter() -> void:
	print("Camera3D State: LOOK")
	target_rot = entity.target.skeleton.rotation.y
	tween_cam_rotate(Tween.EASE_OUT)
	Audio.play_sfx(RegistryAudio.cam_first_person)
	entity.anim_tween.interpolate_property(entity, "arm_length", entity.arm_length, -1.5, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	entity.anim_tween.start()
	entity.anim_wobble.play("Wobble")

func states_physics_process(delta: float) -> int:
	if !target_controlled():
		return State.LOCK
	if rotation_complete:
		_cam_movement(delta)
	if Input.is_action_just_pressed("cam_zoom"):
		Audio.play_sfx(RegistryAudio.cam_third_person)
		return State.ORBI
	return State.NULL

func _cam_movement(delta: float) -> void:
	rotation.x = (Input.get_action_strength("cam_left") - Input.get_action_strength("cam_right")) / 2
	if is_inverted():
		rotation.x = -rotation.x
	rotation.y = (Input.get_action_strength("cam_up") - Input.get_action_strength("cam_down")) / 1.5
	if is_inverted(true):
		rotation.y = -rotation.y
	velocity = velocity.lerp(rotation * sensitivity * 5, delta * rotation_speed)
	entity.rotation.y += (deg_to_rad(velocity.x))
	entity.rotation.x += (deg_to_rad(velocity.y))
	entity.rotation.x = lerp(entity.rotation.x, clamp(entity.rotation.x, deg_to_rad(0), deg_to_rad(45)), track_speed * delta)
	entity.position = lerp(entity.position, entity.target.position + offset, track_speed * delta)

func exit() -> void:
	entity.anim_wobble.stop()
	rotation_complete = false

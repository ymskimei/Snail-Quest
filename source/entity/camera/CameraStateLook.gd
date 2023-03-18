extends CameraStateMain

export var follow_speed = 18
export var rotation_speed = 10
export var offset = Vector3(0, 0.9, 0)

func enter() -> void:
	print("Camera State: LOOK")
	AudioPlayer.play_sfx(AudioPlayer.sfx_cam_first_person)
	entity.anim_tween.interpolate_property(entity, "spring_length", entity.spring_length, -1.5, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	entity.anim_tween.start()
	entity.anim_wobble.play("Wobble")

func physics_process(delta: float) -> int:
	rotation.x = -Input.get_action_strength("cam_right") - -Input.get_action_strength("cam_left")
	rotation.y = Input.get_action_strength("cam_up") - Input.get_action_strength("cam_down")
	velocity = velocity.linear_interpolate(rotation * sensitivity / 3, delta * rotation_speed)
	entity.rotation.y += (deg2rad(velocity.x))
	entity.rotation.x += (deg2rad(velocity.y))
	entity.rotation.x = lerp(entity.rotation.x, clamp(entity.rotation.x, deg2rad(-5), deg2rad(10)), follow_speed * delta)
	entity.translation = lerp(entity.translation, entity.player.translation + offset, follow_speed * delta)
	if Input.is_action_just_pressed("cam_zoom"):
		return State.ORBI
	if entity.player.targeting:
		return State.TARG
	return State.NULL

func exit() -> void:
	AudioPlayer.play_sfx(AudioPlayer.sfx_cam_third_person)

extends CameraStateMain

export var movement_speed: int = 20
export var min_movement_speed: int = 2
export var max_movement_speed: int = 300
export var fov: int = 50
export var min_fov: int = 15
export var max_fov: int = 125

func enter() -> void:
	print("Camera State: FREE")
	tween_cam_reset()

func physics_process(delta: float) -> int:
	cam_fov()
	cam_speed()
	cam_movement(movement_speed, delta)
	entity.camera_lens.fov = lerp(entity.camera_lens.fov, cam_fov(), 0.25)
	if is_instance_valid(entity.cam_target):
		if entity.cam_target is VehicleBody:
			return State.VEHI
		else:
			return State.ORBI
	return State.NULL

func cam_movement(speed, delta: float) -> void:
	entity.global_translation += -get_joy_input().rotated(Vector3.UP, entity.camera_lens.rotation.y) * speed * delta
	rotation.x = Input.get_action_strength("cam_left") - Input.get_action_strength("cam_right")
	rotation.y = Input.get_action_strength("cam_up") - Input.get_action_strength("cam_down")
	velocity = lerp(velocity, rotation * (sensitivity / 3), 0.3)
	entity.camera_lens.rotation.y += deg2rad(velocity.x)
	entity.camera_lens.rotation.x += clamp(deg2rad(velocity.y), -90, 90)

func cam_fov() -> int:
	if Input.is_action_pressed("debug_cam_fov_up") and fov < max_fov:
		fov += 1
	elif Input.is_action_pressed("debug_cam_fov_down") and fov >= min_fov:
		fov += -1
	return fov

func cam_speed() -> int:
	if Input.is_action_pressed("debug_cam_speed_up") and movement_speed < max_movement_speed:
		movement_speed += 1
	elif Input.is_action_pressed("debug_cam_speed_down") and movement_speed >= min_movement_speed:
		movement_speed += -1
	return movement_speed

func get_joy_input() -> Vector3:
	var input: Vector3 = Vector3.ZERO
	input.x = Input.get_action_strength("joy_left") - Input.get_action_strength("joy_right")
	input.z = Input.get_action_strength("joy_up") - Input.get_action_strength("joy_down")
	input.y = Input.get_action_strength("debug_cam_lower") - Input.get_action_strength("debug_cam_higher")
	var input_length = input.length()
	if input_length > 1:
		input /= input_length
	return input

func tween_cam_reset() -> void:
	entity.anim_tween.interpolate_property(entity, "rotation", entity.rotation, Vector3.ZERO, 0.15, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	entity.anim_tween.interpolate_property(entity.camera_lens, "fov", entity.camera_lens.fov, fov, 0.15, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	entity.anim_tween.start()

func exit() -> void:
	entity.camera_lens.rotation = Vector3.ZERO

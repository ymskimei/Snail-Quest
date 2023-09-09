extends CameraStateMain

export var rotation_speed: int = 10
export var movement_speed: int = 25
export var min_movement_speed: int = 2
export var max_movement_speed: int = 300
export var fov: int = 60

func enter() -> void:
	print("Camera State: FREE")
	tween_cam_reset()

func physics_process(delta: float) -> int:
	cam_movement(delta)
	movement_speed()
	if is_instance_valid(entity.cam_target):
		if entity.targeting_vehicle:
			return State.VEHI
		else:
			return State.ORBI
	return State.NULL

func cam_movement(delta: float) -> void:
	entity.global_translation += -get_joy_input().rotated(Vector3.UP, entity.camera_lens.rotation.y) * movement_speed * delta
	rotation.x = Input.get_action_strength("cam_left") - Input.get_action_strength("cam_right")
	rotation.y = Input.get_action_strength("cam_up") - Input.get_action_strength("cam_down")
	velocity = rotation * sensitivity / 7
	entity.camera_lens.rotation.y += (deg2rad(velocity.x))
	entity.camera_lens.rotation.x += clamp(deg2rad(velocity.y), -90, 90)

func movement_speed() -> void:
	if Input.is_action_pressed("debug_cam_speed_up") and movement_speed < max_movement_speed:
		movement_speed += 1
	elif Input.is_action_pressed("debug_cam_speed_down") and movement_speed >= min_movement_speed:
		movement_speed += -1

func get_joy_input() -> Vector3:
	var input : Vector3
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

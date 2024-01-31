extends CameraStateMain

var speed: int = 20

var min_speed: int = 2
var max_speed: int = 300

var fov: int = 50

var min_fov: int = 15
var max_fov: int = 125

func enter() -> void:
	print("Camera3D State: FREE")
	tween_cam_reset()

func physics_process(delta: float) -> int:
	_cam_fov()
	_cam_speed()
	_cam_movement(delta)
	entity.lens.fov = lerp(entity.lens.fov, float(_cam_fov()), 0.25)
	if is_instance_valid(entity.target):
		if entity.target is VehicleBody3D:
			return State.VEHI
		else:
			return State.ORBI
	return State.NULL

func _cam_fov() -> int:
	if Input.is_action_pressed("debug_cam_fov_increase") and fov < max_fov:
		fov += 1
	elif Input.is_action_pressed("debug_cam_fov_decrease") and fov >= min_fov:
		fov += -1
	return fov

func _cam_speed() -> int:
	if Input.is_action_pressed("debug_cam_speed_up") and speed < max_speed:
		speed += 1
	elif Input.is_action_pressed("debug_cam_speed_down") and speed >= min_speed:
		speed += -1
	return speed

func _cam_movement(delta: float) -> void:
	entity.global_position += -get_joy_input().rotated(Vector3.UP, entity.lens.rotation.y) * speed * delta
	rotation.x = Input.get_action_strength("cam_left") - Input.get_action_strength("cam_right")
	rotation.y = Input.get_action_strength("cam_up") - Input.get_action_strength("cam_down")
	velocity = lerp(velocity, (rotation / 50) * fov * (sensitivity / 3), 0.3)
	entity.lens.rotation.y += deg_to_rad(velocity.x)
	entity.lens.rotation.x += clamp(deg_to_rad(velocity.y), -90, 90)

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
	entity.anim_tween.interpolate_value(entity.rotation, "x", 0, 0.15, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	entity.anim_tween.interpolate_value(entity.rotation, "y", 0, 0.15, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	entity.anim_tween.interpolate_value(entity.rotation, "z", 0, 0.15, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	entity.anim_tween.interpolate_value(entity.lens, "fov", fov, 0.15, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	entity.anim_tween.play()

func exit() -> void:
	entity.lens.rotation = Vector3.ZERO

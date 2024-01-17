extends CameraStateMain

var offset: Vector3 = Vector3(0, 0.8, 0)

var track_speed: int = 10
var rotation_speed: int = 5

var fov: int = 60
var arm: int = 7

var boost_fov: int = 80
var boost_arm: int = 6

var distance: int = 0

func enter() -> void:
	print("Camera State: VEHICLE")
	entity.target.connect("boosted", self, "_on_vehicle_boost")
	_tween_cam_reset()
	distance = 0

func unhandled_input(event: InputEvent) -> int:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotation = event.relative
		controller = false
	elif event is InputEventJoypadMotion:
		controller = true
	else:
		rotation = Vector2.ZERO
	return State.NULL

func physics_process(delta: float) -> int:
	_cam_tracking(delta)
	if !entity.target is VehicleBody:
		return State.ORBI
	return State.NULL

func _cam_tracking(delta: float) -> void:
	rotation.x = (Input.get_action_strength("cam_left") - Input.get_action_strength("cam_right")) / 2
	rotation.x += (-Input.get_action_strength("joy_right") + Input.get_action_strength("joy_left")) / 5
	velocity = velocity.linear_interpolate(rotation * sensitivity / 3, delta * rotation_speed)
	entity.rotation.y += (deg2rad(velocity.x))
	entity.translation = lerp(entity.translation, entity.target.translation + offset, track_speed * delta)
	entity.spring_length = lerp(entity.spring_length, clamp(entity.spring_length + distance, 4, 30), 10 * delta)

func _on_vehicle_boost(boosting: bool) -> void:
	if boosting:
		_tween_cam_boost(boost_fov, boost_arm)
	else:
		_tween_cam_boost(fov, arm)

func _tween_cam_boost(set_fov: int, set_arm :float) -> void:
	entity.anim_tween.interpolate_property(entity.camera_lens, "fov", entity.camera_lens.fov, set_fov, 0.25, Tween.TRANS_LINEAR, Tween.EASE_IN)
	entity.anim_tween.interpolate_property(entity, "spring_length", entity.spring_length, set_arm, 0.25, Tween.TRANS_LINEAR, Tween.EASE_IN)
	entity.anim_tween.start()

func _tween_cam_reset() -> void:
	entity.anim_tween.interpolate_property(entity.camera_lens, "fov", entity.camera_lens.fov, fov, 0.25, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	entity.anim_tween.interpolate_property(entity, "spring_length", entity.spring_length, arm, 0.4, Tween.TRANS_EXPO, Tween.EASE_OUT)
	entity.anim_tween.start()

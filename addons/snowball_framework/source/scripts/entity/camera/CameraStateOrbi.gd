extends CameraStateMain

var offset = Vector3(0, 0.5, 0)
	
var track_speed: float = 3.5
var rotation_speed: int = 10

var lock_high_arm: float = 0.0
var lock_high_lens: float = 0.3

var lock_low_arm: float = -0.85
var lock_low_lens: float = -0.025

var lock_default_arm: float = -0.2
var lock_default_lens: float = 0.075

var fov: int = 40
var arm: float = 6

var distance: float = 0
var input_spin: int = 0

var look_around: bool
var zoom_mode: bool
var can_exit_mode: bool

var spin_timer: Timer = Timer.new()
var look_timer: Timer = Timer.new()

func enter() -> void:
	print("Camera3D State: ORBIT")
	tween_cam_pan(lock_default_arm, lock_default_lens)
	_tween_cam_reset()
	_add_control_timers()
	zoom_mode = false
	look_around = false
	distance = 0

func states_unhandled_input(event: InputEvent) -> int:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotation = event.relative
		controller = false
	elif event is InputEventJoypadMotion:
		controller = true
	else:
		rotation = Vector2.ZERO
	return State.NULL

func states_physics_process(delta: float) -> int:
	if !target_controlled():
		return State.LOCK
	if entity.target is VehicleBody3D:
		return State.VEHI
	if entity.target is Entity and entity.target.targeting:
		return State.TARG
	if look_around:
		return State.LOOK
	if is_instance_valid(entity.target):
		_cam_tracking(delta)
		_cam_panning(delta)
		_cam_velocity(delta)
		_cam_reset()
	else:
		return State.FREE
	return State.NULL

func _cam_tracking(delta: float) -> void:
	rotation.x = Input.get_action_strength(Device.stick_alt_left) - Input.get_action_strength(Device.stick_alt_right)
	if is_inverted():
			rotation.x = -rotation.x
	rotation.x += (-Input.get_action_strength("joy_right") + Input.get_action_strength("joy_left")) / 2
	entity.position = lerp(entity.position, entity.target.position + offset, track_speed * delta)
	entity.arm_length = lerp(entity.arm_length, clamp(entity.arm_length + distance, 4, 30), 10 * delta)
	entity.rotation.y += (deg_to_rad(velocity.x))

func _cam_panning(delta: float) -> void:
	var distance_to_target = entity.lens.get_global_translation().distance_to(entity.target.get_global_translation())
	if distance_to_target <= 1.5:
		tween_cam_pan(lock_low_arm, lock_low_lens)
	elif distance_to_target >= 2:
		if Input.is_action_just_pressed(Device.button_right):
			look_timer.start()
		if Input.is_action_just_released(Device.button_right):
			zoom_mode = true
		if !zoom_mode:
			_cam_lifting(delta)
		else:
			cam_zooming(delta)
			
func _cam_velocity(delta: float) -> void:
	velocity = velocity.lerp(rotation * sensitivity * 3, delta * rotation_speed)

func _cam_lifting(delta: float) -> void:
	rotation.y = Input.get_action_strength(Device.stick_alt_up) - Input.get_action_strength(Device.stick_alt_down)
	if is_inverted(true):
			rotation.y = -rotation.y
	entity.rotation.x += velocity.y * delta
	entity.rotation.x = lerp(entity.rotation.x, clamp(entity.rotation.x, deg_to_rad(-60), deg_to_rad(-15)), 6 * delta)

func cam_zooming(delta: float) -> void:
	if Input.is_action_pressed(Device.stick_alt_up):
		distance -= 15 * delta
	elif Input.is_action_pressed(Device.stick_alt_down):
		distance += 15 * delta
	else:
		distance = 0
	if Input.is_action_just_pressed(Device.button_right):
		can_exit_mode = true
	if can_exit_mode and Input.is_action_just_released(Device.button_right):
		can_exit_mode = false
		zoom_mode = false

func _cam_reset() -> void:
	if Input.is_action_just_pressed(Device.stick_alt_left) or Input.is_action_just_pressed(Device.stick_alt_right) or Input.is_action_just_pressed(Device.stick_alt_up) or Input.is_action_just_pressed(Device.stick_alt_down):
		input_spin += 1
		spin_timer.start()
		if input_spin >= 4:
			_tween_cam_reset()

func _add_control_timers() -> void:
	if !is_instance_valid(get_node_or_null("SpinTimer")):
		spin_timer.set_one_shot(true)
		spin_timer.set_wait_time(0.5)
		spin_timer.connect("timeout", Callable(self, "_on_spin_timer"))
		spin_timer.set_name("SpinTimer")
		add_child(spin_timer)
	if !is_instance_valid(get_node_or_null("LookTimer")):
		look_timer.set_one_shot(true)
		look_timer.set_wait_time(0.25)
		look_timer.connect("timeout", Callable(self, "_on_look_timer"))
		look_timer.set_name("LookTimer")
		add_child(look_timer)

func _on_spin_timer() -> void:
	input_spin = 0

func _on_look_timer() -> void:
	if Input.is_action_pressed(Device.button_right):
		look_around = true

func _tween_cam_zoom(dist: float) -> void:
	entity.anim_tween.interpolate_value(entity, "arm_length", entity.arm_length + dist, 0.4, Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
	entity.anim_tween.play()

func _tween_cam_reset() -> void:
	entity.anim_tween.interpolate_value(entity.lens, "fov", fov, 0.25, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	entity.anim_tween.interpolate_value(entity, "arm_length", arm, 0.4, Tween.TRANS_EXPO, Tween.EASE_OUT)
	entity.anim_tween.play()

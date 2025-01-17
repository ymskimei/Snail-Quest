extends CameraStateMain

var track_speed: float = 8
var rotation_speed: int = 16

var input_spin: int = 0

var spin_timer: Timer = Timer.new()
var look_timer: Timer = Timer.new()

func enter() -> void:
	print("Camera State: ORBIT")
#	entity.anim_tween.interpolate_property(entity.lens, "fov", entity.lens.fov, 45, 0.5, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
#	entity.anim_tween.interpolate_property(entity, "spring_length", entity.spring_length, 6, 0.5, Tween.TRANS_SINE, Tween.EASE_IN_OUT)

	if !is_instance_valid(get_node_or_null("SpinTimer")):
		spin_timer.set_one_shot(true)
		spin_timer.set_wait_time(0.5)
		spin_timer.connect("timeout", self, "_on_spin_timer")
		spin_timer.set_name("SpinTimer")
		add_child(spin_timer)

func unhandled_input(event: InputEvent) -> int:
	.unhandled_input(event)
	return State.NULL

func physics_process(delta: float) -> int:
	if !target_controlled():
		return State.LOCK

	if is_instance_valid(entity.target):

		if "target" in entity.target:
			if  entity.target is VehicleBody:
				return State.VEHI

			if entity.target.targeting:
				return State.TARG

		entity.translation.x = lerp(entity.translation.x, entity.target.translation.x, track_speed * delta)
		entity.translation.y = lerp(entity.translation.y, entity.target.translation.y + 0.55, track_speed * 0.45 * delta)
		entity.translation.z = lerp(entity.translation.z, entity.target.translation.z, track_speed * delta)
		
		rotation.y = (Input.get_action_strength(Device.stick_alt_left) - Input.get_action_strength(Device.stick_alt_right)) * 2.25
		if is_inverted(true):
			rotation.y = -rotation.y
		#rotation.y += (Input.get_action_strength(Device.stick_main_left) - Input.get_action_strength(Device.stick_main_right)) * 1.5

		rotation.x = (Input.get_action_strength(Device.stick_alt_up) - Input.get_action_strength(Device.stick_alt_down)) * 1.5

		velocity = velocity.linear_interpolate(rotation * sensitivity, rotation_speed * delta)
		
		entity.rotation.y += (deg2rad(velocity.y))
		entity.rotation.x += (deg2rad(velocity.x) * 1.2)
		#entity.rotation.x = (clamp(entity.rotation.x, deg2rad(-90), deg2rad(0)))
		var angle_range: float = Utility.normalize_range(rad2deg(entity.rotation.x), 0, -90)

		entity.set_length(lerp(5, 12, angle_range))
		entity.lens.set_fov(lerp(40, 60, angle_range))

		if Input.is_action_just_pressed(Device.stick_alt_left) or Input.is_action_just_pressed(Device.stick_alt_right):
			input_spin += 1
			spin_timer.start()
			if input_spin >= 3:
				return State.LOOK

	else:
		return State.FREE

	if entity.target is VehicleBody:
		return State.VEHI

	return State.NULL

func _on_spin_timer() -> void:
	input_spin = 0

func _tween_cam_mode(arm_rot: float = -15, lens_rot: float = 5, fov: int = 45, length: float = 6) -> void:
	entity.anim_tween.interpolate_property(entity, "rotation_degrees:x", entity.rotation_degrees.x, arm_rot, 0.25, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	entity.anim_tween.interpolate_property(entity.lens, "rotation_degrees:x", entity.lens.rotation_degrees.x, lens_rot, 0.25, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	entity.anim_tween.interpolate_property(entity.lens, "fov", entity.lens.fov, fov, 0.25, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	entity.anim_tween.interpolate_property(entity, "spring_length", entity.spring_length, length, 0.4, Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
	entity.anim_tween.start()

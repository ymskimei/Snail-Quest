extends CameraStateMain

var offset: Vector3 = Vector3(0, 0.1, 0)

var track_speed: int = 18
var rotation_speed: int = 10

var zoom: float = 0
 
var input_spin: int = 0
var spin_timer: Timer = Timer.new()

func enter() -> void:
	print("Camera State: LOOK")
	entity.looking = true
	target_rot = entity.target.skeleton.rotation.y
	tween_cam_rotate(Tween.EASE_OUT)

	if !is_instance_valid(get_node_or_null("SpinTimer")):
		spin_timer.set_one_shot(true)
		spin_timer.set_wait_time(0.5)
		spin_timer.connect("timeout", self, "_on_spin_timer")
		spin_timer.set_name("SpinTimer")
		add_child(spin_timer)

	Auto.audio.play_sfx(RegistryAudio.cam_first_person)

	entity.anim_tween.interpolate_property(entity, "spring_length", entity.spring_length, -1.5, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	entity.anim_tween.start()

	entity.anim_wobble.play("Wobble")

func unhandled_input(event: InputEvent) -> int:
	.unhandled_input(event)
	if event is InputEventJoypadMotion and event.axis == 6:
		zoom = event.axis_value * 30
	return State.NULL

func physics_process(delta: float) -> int:
	if !target_controlled():
		return State.LOCK

	if rotation_complete:
		rotation.y = (Input.get_action_strength(Auto.input.stick_alt_left) - Input.get_action_strength(Auto.input.stick_alt_right)) / 2
		rotation.x = (Input.get_action_strength(Auto.input.stick_alt_up) - Input.get_action_strength(Auto.input.stick_alt_down)) / 1.5
		if is_inverted():
			rotation.x = -rotation.x
		if is_inverted(true):
			rotation.y = -rotation.y

		velocity = velocity.linear_interpolate(rotation * sensitivity * 5, delta * rotation_speed)
		entity.rotation.x += (deg2rad(velocity.x))
		entity.rotation.y += (deg2rad(velocity.y))

		entity.rotation.x = lerp(entity.rotation.x, clamp(entity.rotation.x, deg2rad(0), deg2rad(45)), track_speed * delta)
		entity.translation = lerp(entity.translation, entity.target.translation + offset, track_speed * delta)

		if Input.is_action_just_pressed(Auto.input.stick_alt_left) or Input.is_action_just_pressed(Auto.input.stick_alt_right):
			input_spin += 1
			spin_timer.start()
			if input_spin >= 3:
				Auto.audio.play_sfx(RegistryAudio.cam_third_person)
				return State.ORBI

		if Input.is_action_pressed(Auto.input.trigger_left):
			zoom = 30
		elif Input.is_action_just_released(Auto.input.trigger_left):
			zoom = 0
		entity.lens.fov = lerp(entity.lens.fov, 45 - zoom, 5 * delta)

	return State.NULL

func _on_spin_timer() -> void:
	input_spin = 0

func exit() -> void:
	entity.looking = false
	entity.anim_wobble.stop()
	rotation_complete = false

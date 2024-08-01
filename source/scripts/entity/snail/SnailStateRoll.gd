extends SnailState

var roll_sound: AudioStreamPlayer3D 

func enter() -> void:
	print("Snail State: ROLL")
	roll_sound = AudioStreamPlayer3D.new()
	roll_sound.set_stream(load("res://assets/sound/snail_roll.ogg"))
	add_child(roll_sound)
	#roll_sound.play()

	entity.anim_states.travel("SnailRoll")

func unhandled_input(event: InputEvent) -> int:
	if is_on_surface():
		if event.is_action_pressed(Device.action_main):
			return State.JUMP
	return State.NULL

func physics_process(delta: float) -> int:
	set_rotation(delta)

	if !Input.is_action_pressed(Device.trigger_right):
		return State.MOVE

	if entity.direction.length() >= 1.1:
		if entity.move_momentum < entity.max_momentum:
			entity.move_momentum += 0.25 * delta
	else:
		entity.move_momentum = 0.0

	if entity.jump_in_memory or entity.boost_momentum != Vector3.ZERO:
		return State.JUMP

	if entity.is_submerged():
		set_movement(delta, 1.0 + entity.move_momentum, true, false, 0.6, 0.8)
	else:
		set_movement(delta, 1.0 + entity.move_momentum, true, false, 0.6, 1.0)

	entity.anim_tree.set("parameters/SnailRoll/TimeScale/scale", entity.direction.length() * 1.2)

	if entity.direction.length() >= 0.1:
		roll_sound.set_unit_db(linear2db(entity.direction.length()))
		roll_sound.set_pitch_scale(entity.direction.length())
	else:
		roll_sound.set_unit_db(linear2db(0.0))
		roll_sound.set_pitch_scale(0.1)


	if !is_on_surface(true):
		entity.can_late_jump = true
		return State.FALL
	return State.NULL

func exit() -> void:
	roll_sound.stop()
	roll_sound.queue_free()
	entity.anim_tree.set("parameters/SnailRoll/TimeScale/scale", 1.0)

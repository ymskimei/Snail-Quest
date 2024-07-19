extends SnailState

func enter() -> void:
	print("Snail State: IDLE")
	entity.anim_states.travel("SnailIdle")
	entity.move_momentum = 0
	entity.boosting = false

func unhandled_input(event: InputEvent) -> int:
	if entity.can_be_controlled():
		if event.is_action_pressed(Device.action_main):
			return State.JUMP
		if event.is_action_pressed(Device.action_alt):
			return State.SPIN
		if event.is_action_pressed(Device.trigger_right):
			return State.HIDE
	return State.NULL

func physics_process(delta: float) -> int:
	set_gravity(delta)
	set_movement(delta)
	set_rotation(delta)
	boost_momentum()

	if entity.direction.length() >= 0.1:
		return State.MOVE

	if entity.jump_in_memory or entity.boost_momentum != Vector3.ZERO:
		return State.JUMP

	if !is_on_surface():
		return State.FALL

	return State.NULL

func exit() -> void:
	pass


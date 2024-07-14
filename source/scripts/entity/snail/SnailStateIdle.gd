extends SnailStateMain

func enter() -> void:
	print("Snail State: IDLE")
	entity.anim_states.travel("SnailIdle")
	entity.move_momentum = 0
	entity.boosting = false

func unhandled_input(event: InputEvent) -> int:
	if is_on_surface():
		if event.is_action_pressed(Device.action_main):
			return State.JUMP
		if event.is_action_pressed(Device.trigger_right):
			return State.ROLL
	return State.NULL

func physics_process(delta: float) -> int:
	set_gravity(delta)
	set_movement(delta)
	set_rotation(delta)

	if entity.direction != Vector3.ZERO:
		return State.MOVE

	if entity.jump_in_memory:
		return State.JUMP

	if !is_on_surface():
		return State.FALL

	return State.NULL

func exit() -> void:
	pass


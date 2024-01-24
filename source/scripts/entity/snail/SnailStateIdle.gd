extends SnailStateMain

func enter() -> void:
	print("Snail State: IDLE")
	entity.anim.play("SnailIdle")

func unhandled_input(event: InputEvent) -> int:
	if !entity.can_interact and event.is_action_pressed("action_main"):
		return State.JUMP
	if event.is_action_pressed("action_defense"):
		return State.HIDE
	needle()
	mallet()
	return State.NULL

func physics_process(delta: float) -> int:
	.physics_process(delta)
	if entity.jump_in_memory and !entity.can_interact:
		return State.JUMP
	if direction != Vector3.ZERO:
		if is_on_floor():
			return State.MOVE
		else:
			return State.FALL
	return State.NULL
	
func integrate_forces(state: PhysicsDirectBodyState) -> int:
	.integrate_forces(state)
	apply_movement(state, 0)
	return State.NULL

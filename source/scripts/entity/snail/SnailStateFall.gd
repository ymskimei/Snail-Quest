extends SnailStateMain

func enter() -> void:
	print("Snail State: FALL")
	entity.anim.play("SnailFall")

func unhandled_input(event: InputEvent) -> int:
	if entity.attach_point and event.is_action_pressed("action_defense"):
		if entity.input == Vector3.ZERO:
			return State.HIDE
		else:
			return State.DODG
	needle()
	mallet()
	return State.NULL

func physics_process(delta: float) -> int:
	.physics_process(delta)
#	if entity.input == Vector3.ZERO:
#		entity.linear_velocity.x += entity.linear_velocity.x * air_friction * delta
#		entity.linear_velocity.z += entity.linear_velocity.z * air_friction * delta
#	else:
#		entity.linear_velocity.x += entity.linear_velocity.x * delta
#		entity.linear_velocity.z += entity.linear_velocity.z * delta
	if is_on_floor():
		if entity.direction != Vector3.ZERO:
			return State.MOVE
		else:
			return State.IDLE
	return State.NULL

func integrate_forces(state: PhysicsDirectBodyState) -> int:
	.integrate_forces(state)
	apply_movement(state, 0.4)
	return State.NULL

func exit() -> void:
	pass

extends SnailStateMain

func enter() -> void:
	print("Snail State: FALL")
	entity.anim.play("SnailFall")

func states_unhandled_input(event: InputEvent) -> int:
	if entity.holding_point and event.is_action_pressed("action_defense"):
		if input == Vector3.ZERO:
			return State.HIDE
		else:
			return State.DODG
	if event.is_action_pressed("action_main"):
		entity.jump_memory()
	needle()
	mallet()
	return State.NULL

func states_physics_process(delta: float) -> int:
	super.states_physics_process(delta)
	if entity.ledge_usable and !entity.ray_front_top.is_colliding() and entity.ray_front_bottom.is_colliding():
		return State.HANG
#	if entity.input == Vector3.ZERO:
#		entity.linear_velocity.x += entity.linear_velocity.x * air_friction * delta
#		entity.linear_velocity.z += entity.linear_velocity.z * air_friction * delta
#	else:
#		entity.linear_velocity.x += entity.linear_velocity.x * delta
#		entity.linear_velocity.z += entity.linear_velocity.z * delta
	if is_on_floor() and entity.ray_bottom.is_colliding():
		if direction != Vector3.ZERO:
			return State.MOVE
		else:
			return State.IDLE
	return State.NULL

func states_integrate_forces(state: PhysicsDirectBodyState3D) -> int:
	super.states_integrate_forces(state)
	if entity.is_controlled():
		apply_movement(state, 0.25)
	return State.NULL

func exit() -> void:
	pass

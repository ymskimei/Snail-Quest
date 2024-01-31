extends SnailStateMain

func enter() -> void:
	print("Snail State: HANG")
	entity.linear_velocity = Vector3.ZERO
	entity.anim.play("SnailLedge")
	
func states_input(event: InputEvent) -> int:
	if event.is_action_pressed("action_main"):
		entity.ledge()
		return State.JUMP
	if event.is_action_pressed("action_defense"):
		entity.ledge()
		return State.FALL
	return State.NULL

func states_physics_process(delta: float) -> int:
	super.states_physics_process(delta)
	return State.NULL

func states_integrate_forces(state: PhysicsDirectBodyState3D) -> int:
	set_hang_align(state)
	apply_shimmy(state, 0.2)
	if Input.is_action_pressed("joy_right"):
		entity.anim.play("SnailShimmyRight")
	elif Input.is_action_pressed("joy_left"):
		entity.anim.play("SnailShimmyLeft")
	else:
		entity.anim.play("SnailHang")	
	if entity.ray_front_top.is_colliding() or !entity.ray_front_bottom.is_colliding():
		return State.FALL
	return State.NULL

func exit() -> void:
	pass

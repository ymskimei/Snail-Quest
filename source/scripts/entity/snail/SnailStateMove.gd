extends SnailStateMain

func enter() -> void:
	print("Snail State: MOVE")
	entity.anim.play("SnailMove")

func unhandled_input(event: InputEvent) -> int:
	if !entity.can_interact and event.is_action_pressed("action_main") and is_on_floor():
		return State.JUMP
	#if event.is_action_pressed("action_defense") or roll(event):
	#	return State.DODG
	needle()
	mallet()
	return State.NULL

func physics_process(delta: float) -> int:
	.physics_process(delta)
	#var anim_speed = clamp((abs(entity.velocity.x) + abs(entity.velocity.z)), 0, 2)
	#entity.animator.set_speed_scale(anim_speed)
	if !direction:
		return State.IDLE
	return State.NULL

func integrate_forces(state: PhysicsDirectBodyState) -> int:
	.integrate_forces(state)
	apply_movement(state, 1.3)
	if !is_on_floor():
		entity.apply_central_impulse(2 * entity.global_transform.basis.y)
		return State.FALL
	return State.NULL

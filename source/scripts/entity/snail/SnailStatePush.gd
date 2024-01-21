extends SnailStateMain

func enter() -> void:
	print("Snail State: PUSH")
	entity.anim.play("SnailPress")
	yield(entity.anim, "animation_finished")
	entity.anim.play("SnailPush")
	entity.linear_damp = 70

func unhandled_input(event: InputEvent) -> int:
	return State.NULL

func physics_process(delta: float) -> int:
	.physics_process(delta)
	var anim_speed = clamp((abs(entity.linear_velocity.x) + abs(entity.linear_velocity.y) + abs(entity.linear_velocity.z)), 0, 2) * 0.75
	entity.anim.set_speed_scale(anim_speed)
	if !entity.pushing:
		return State.MOVE
	return State.NULL

func integrate_forces(state: PhysicsDirectBodyState) -> int:
	.integrate_forces(state)
	apply_movement(state, 8)
	if !is_on_floor() and !entity.jump_in_memory:
		entity.apply_central_impulse(3 * entity.global_transform.basis.y)
		return State.FALL
	return State.NULL

func exit() -> void:
	entity.anim.set_speed_scale(1)
	entity.linear_damp = -1

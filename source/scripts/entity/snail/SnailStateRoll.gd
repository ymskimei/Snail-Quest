extends SnailStateMain

func enter() -> void:
	print("Snail State: ROLL")
	entity.animator.play("SnailHide")
	await entity.animator.animation_finished
	entity.animator.play("SnailHidden")
	SB.audio.play_sfx(SB.audio.sfx_snail_shell_in)

func states_unhandled_input(_event: InputEvent) -> int:
	if Input.is_action_just_released("action_defense"):
		return State.IDLE
	return State.NULL

func states_physics_process(delta: float) -> int:
	super.states_physics_process(delta)
	if entity.controllable and Input.is_action_just_pressed("action_main") and !shell_jumped:
		shell_jumped = true
		return State.JUMP
	return State.NULL

func states_integrate_forces(state: PhysicsDirectBodyState3D) -> int:
	super.states_integrate_forces(state)
	apply_movement(state, 1.5, true)
	return State.NULL

#	.physics_process(delta)
#	apply_facing(0.3)
#	apply_movement(delta, true, deg2rad(1))
#	apply_gravity(delta)
#	entity.snap_vector = Vector3.DOWN
#	if entity.input == Vector3.ZERO:
#		entity.velocity.x = lerp(entity.velocity.x, 0, 0.03)
#		entity.velocity.z = lerp(entity.velocity.z, 0, 0.03)
#		entity.animator.set_speed_scale(lerp(entity.animator.get_playing_speed(), 0, 0.03))
#	else:
#		var anim_speed = clamp((abs(entity.input.x) + abs(entity.input.z)), 0, 2)
#		entity.animator.set_speed_scale(anim_speed)

func exit() -> void:
	entity.skeleton.position = Vector3(0, -0.45, 0.05)
	entity.skeleton.rotation = Vector3.ZERO
	SB.audio.play_sfx(SB.audio.sfx_snail_shell_out)

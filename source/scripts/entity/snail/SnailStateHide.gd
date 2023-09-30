extends SnailStateMain

func enter() -> void:
	print("Snail State: HIDE")
	entity.animator.set_speed_scale(1)
	entity.animator.play("SnailHide")
	yield(entity.animator, "animation_finished")
	entity.animator.play("SnailHidden")
	entity.in_shell = true

func input(_event: InputEvent) -> int:
	if entity.can_move:
		if entity.controllable and Input.is_action_just_released("action_defense"):
			return State.IDLE
		if entity.controllable and Input.is_action_just_pressed("action_main") and !shell_jumped:
			shell_jumped = true
			return State.JUMP
	return State.NULL

func physics_process(delta: float) -> int:
	.physics_process(delta)
	if entity.can_move:
		if entity.controllable and direction != Vector3.ZERO and is_on_floor:
			return State.ROLL
	return State.NULL

func integrate_forces(state: PhysicsDirectBodyState) -> int:
	.integrate_forces(state)
	if entity.can_move:
		apply_movement(entity, state, 2.05)
	return State.NULL

func exit() -> void:
	entity.animator.play_backwards("SnailHide")
	AudioPlayer.play_pos_sfx(AudioPlayer.sfx_snail_shell_out, entity.global_translation)
	entity.in_shell = false

extends PlayerStateMain

func enter() -> void:
	print("Player State: HIDE")
	entity.animator.set_speed_scale(1)
	entity.animator.play("PlayerTuckDefault")
	yield(entity.animator, "animation_finished")
	entity.animator.play("PlayerHideDefault")
	entity.in_shell = true

func input(_event: InputEvent) -> int:
	if entity.can_move:
		if entity.is_active_player and Input.is_action_just_released("action_defense"):
			entity.animator.play_backwards("PlayerTuckDefault")
			AudioPlayer.play_pos_sfx(AudioPlayer.sfx_snail_shell_out, entity.global_translation)
			return State.IDLE
		if entity.is_active_player and Input.is_action_just_pressed("action_main") and !shell_jumped:
			AudioPlayer.play_pos_sfx(AudioPlayer.sfx_snail_shell_out, entity.global_translation)
			shell_jumped = true
			return State.JUMP
	return State.NULL

func physics_process(delta: float) -> int:
	.physics_process(delta)
	return State.NULL

func integrate_forces(state) -> int:
	.integrate_forces(state)
	return State.NULL

func exit() -> void:
	entity.in_shell = false

extends SnailStateMain

func enter() -> void:
	print("Snail State: HIDE")
	AudioPlayer.play_pos_sfx(AudioPlayer.sfx_snail_shell_in, entity.global_translation)
	entity.anim.play("SnailHide")
	yield(entity.anim, "animation_finished")
	entity.anim.play("SnailHidden")
	entity.in_shell = true

func input(event: InputEvent) -> int:
	if event.is_action_released("action_defense"):
		return State.IDLE
	if event.is_action_pressed("action_main") and !shell_jumped:
		shell_jumped = true
		return State.JUMP
	return State.NULL

func physics_process(delta: float) -> int:
	.physics_process(delta)
	if direction != Vector3.ZERO and is_on_floor():
		return State.ROLL
	return State.NULL

func integrate_forces(state: PhysicsDirectBodyState) -> int:
	.integrate_forces(state)
	return State.NULL

func exit() -> void:
	AudioPlayer.play_pos_sfx(AudioPlayer.sfx_snail_shell_out, entity.global_translation)
	entity.anim.play_backwards("SnailHide")
	#yield(entity.anim, "animation_finished")
	entity.in_shell = false

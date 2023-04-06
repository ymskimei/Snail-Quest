extends PlayerStateMain

func enter() -> void:
	print("Player State: HIDE")
	entity.animator.set_speed_scale(1)
	entity.animator.play("Tuck")
	yield(entity.animator, "animation_finished")
	entity.animator.play("Hide")
	AudioPlayer.play_sfx(AudioPlayer.sfx_snail_shell_in)
	entity.can_move = false

func input(_event: InputEvent) -> int:
	if Input.is_action_just_released("action_defense"):
		entity.animator.set_speed_scale(-1)
		entity.animator.play("Tuck")
		#yield(entity.animator, "animation_finished")
		return State.IDLE
	return State.NULL

func physics_process(delta: float) -> int:
	.physics_process(delta)
	entity.snap_vector = Vector3.DOWN
	entity.velocity.x = 0
	entity.velocity.z = 0
	return State.NULL

func exit() -> void:
	AudioPlayer.play_sfx(AudioPlayer.sfx_snail_shell_out)
	entity.can_move = true

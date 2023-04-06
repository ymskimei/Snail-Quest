extends PlayerStateMain

func enter() -> void:
	print("Player State: ROLL")
	entity.animator.set_speed_scale(1)
	entity.animator.play("Tuck")
	yield(entity.animator, "animation_finished")
	entity.speed *= 1.7
	entity.animator.play("Roll")
	AudioPlayer.play_sfx(AudioPlayer.sfx_snail_shell_in)

func input(_event: InputEvent) -> int:
	if Input.is_action_just_released("action_defense"):
		return State.IDLE
	return State.NULL

func physics_process(delta: float) -> int:
	.physics_process(delta)
	apply_facing(0.3)
	entity.snap_vector = Vector3.DOWN
	if entity.input == Vector3.ZERO:
		entity.velocity.x = lerp(entity.velocity.x, 0, 0.03)
		entity.velocity.z = lerp(entity.velocity.z, 0, 0.03)
		entity.animator.set_speed_scale(lerp(entity.animator.get_playing_speed(), 0, 0.03))
	else:
		var anim_speed = clamp((abs(entity.input.x) + abs(entity.input.z)), 0, 2)
		entity.animator.set_speed_scale(anim_speed)
	return State.NULL

func exit() -> void:
	entity.speed = entity.resource.speed
	AudioPlayer.play_sfx(AudioPlayer.sfx_snail_shell_out)

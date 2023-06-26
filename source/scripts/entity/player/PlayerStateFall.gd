extends PlayerStateMain

export var air_friction = -3.5

func enter() -> void:
	print("Player State: FALL")
	yield(entity.animator, "animation_finished")
	entity.animator.set_speed_scale(1)
	entity.animator.play("PlayerFallDefault")

func input(_event: InputEvent) -> int:
	if entity.is_active_player and Input.is_action_just_pressed("action_defense"):
		AudioPlayer.play_pos_sfx(AudioPlayer.sfx_snail_shell_in, entity.global_translation)
		if entity.input == Vector3.ZERO:
			return State.HIDE
		else:
			return State.DODG
	needle()
	mallet()
	return State.NULL

func physics_process(delta: float) -> int:
	.physics_process(delta)
	if dodge_roll():
		AudioPlayer.play_pos_sfx(AudioPlayer.sfx_snail_shell_in, entity.global_translation)
		return State.DODG
#	if entity.input == Vector3.ZERO:
#		entity.linear_velocity.x += entity.linear_velocity.x * air_friction * delta
#		entity.linear_velocity.z += entity.linear_velocity.z * air_friction * delta
#	else:
#		entity.linear_velocity.x += entity.linear_velocity.x * delta
#		entity.linear_velocity.z += entity.linear_velocity.z * delta
	if is_on_floor:
		if entity.is_active_player and entity.input != Vector3.ZERO:
			return State.MOVE
		else:
			return State.IDLE
	return State.NULL

func integrate_forces(state) -> int:
	.integrate_forces(state)
	apply_movement()
	return State.NULL

func exit() -> void:
	entity.speed = entity.resource.speed

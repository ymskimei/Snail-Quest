extends PlayerStateMain

func enter() -> void:
	print("Player State: IDLE")
	entity.speed = entity.resource.speed
	entity.animator.set_speed_scale(1)
	entity.animator.play("PlayerIdleDefault")

func input(_event: InputEvent) -> int:
	if entity.is_active_player and !entity.can_interact and Input.is_action_just_pressed("action_main") and entity.ray_down.is_colliding():
		return State.JUMP
	if entity.is_active_player and Input.is_action_just_pressed("action_defense") and entity.ray_down.is_colliding():
		AudioPlayer.play_pos_sfx(AudioPlayer.sfx_snail_shell_in, entity.global_translation)
		return State.HIDE
	needle()
	mallet()
	return State.NULL

func physics_process(delta: float) -> int:
	.physics_process(delta)
	if dodge_roll():
		AudioPlayer.play_pos_sfx(AudioPlayer.sfx_snail_shell_in, entity.global_translation)
		return State.DODG
	if entity.is_active_player and entity.input != Vector3.ZERO and entity.ray_down.is_colliding():
		return State.MOVE
	elif !entity.ray_down.is_colliding():
		return State.FALL
	return State.NULL
	
func integrate_forces(state) -> int:
	.integrate_forces(state)
	apply_movement()
	return State.NULL

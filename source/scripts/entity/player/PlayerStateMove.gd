extends PlayerStateMain

func enter() -> void:
	print("Player State: MOVE")
	entity.speed = entity.resource.speed
	entity.animator.set_speed_scale(1)
	entity.animator.play("PlayerMoveDefault")

func input(_event: InputEvent) -> int:
	if entity.can_move:
		if entity.is_active_player and !entity.can_interact and Input.is_action_just_pressed("action_main") and is_on_floor:
			return State.JUMP
		if entity.is_active_player and Input.is_action_just_pressed("action_defense"):
			AudioPlayer.play_pos_sfx(AudioPlayer.sfx_snail_shell_in, entity.global_translation)
			return State.DODG
		needle()
		mallet()
	return State.NULL

func physics_process(delta: float) -> int:
	.physics_process(delta)
	if entity.can_move:
		if dodge_roll():
			AudioPlayer.play_pos_sfx(AudioPlayer.sfx_snail_shell_in, entity.global_translation)
			return State.DODG
	#var anim_speed = clamp((abs(entity.velocity.x) + abs(entity.velocity.z)), 0, 2)
	#entity.animator.set_speed_scale(anim_speed)
	if !is_on_floor:
		return State.JUMP
	if direction == Vector3.ZERO:
		return State.IDLE
	return State.NULL

func integrate_forces(state) -> int:
	.integrate_forces(state)
	if entity.can_move:
		apply_movement()
	return State.NULL

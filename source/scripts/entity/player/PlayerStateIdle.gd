extends PlayerStateMain

func enter() -> void:
	print("Player State: IDLE")
	entity.speed = entity.resource.speed
	entity.animator.set_speed_scale(1)
	entity.animator.play("SnailIdle")

func input(_event: InputEvent) -> int:
	if entity.can_move:
		if entity.is_active_player and !entity.can_interact and Input.is_action_just_pressed("action_main") and is_on_floor:
			return State.JUMP
		if entity.is_active_player and Input.is_action_just_pressed("action_defense") and is_on_floor:
			AudioPlayer.play_pos_sfx(AudioPlayer.sfx_snail_shell_in, entity.global_translation)
			return State.HIDE
		needle()
		mallet()
	return State.NULL

func physics_process(delta: float) -> int:
	.physics_process(delta)
	if entity.can_move:
		if entity.is_active_player and direction != Vector3.ZERO and is_on_floor:
			return State.MOVE
	elif !is_on_floor:
		return State.FALL
	return State.NULL
	
func integrate_forces(state: PhysicsDirectBodyState) -> int:
	.integrate_forces(state)
	if entity.can_move:
		apply_movement(state, 2.05)
	return State.NULL

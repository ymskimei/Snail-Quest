extends SnailStateMain

var can_jump : bool

func enter() -> void:
	print("Snail State: JUMP")
	can_jump = true
	var jump_timer = Timer.new()
	jump_timer.set_wait_time(0.2)
	jump_timer.one_shot = true
	jump_timer.connect("timeout", self, "on_timeout")
	add_child(jump_timer)
	jump_timer.start()
	entity.animator.set_speed_scale(1)
	if jump_combo >= 2:
		entity.animator.play("SnailFlip")
	elif jump_combo == 1:
		jump_combo += 1
		entity.animator.play("SnailJump")
		jump_combo_timer.start()
	else:
		jump_combo += 1
		entity.animator.play("SnailJump")

func input(_event: InputEvent) -> int:
	if entity.can_move:
		if Input.is_action_just_pressed("action_defense"):
			if entity.input == Vector3.ZERO:
				return State.HIDE
			else:
				return State.DODG
	return State.NULL

func physics_process(delta: float) -> int:
	.physics_process(delta)
	if entity.can_move:
		if roll():
			AudioPlayer.play_pos_sfx(AudioPlayer.sfx_snail_shell_in, entity.global_translation)
			return State.DODG
	if !can_jump:
		return State.FALL
	return State.NULL

func integrate_forces(state: PhysicsDirectBodyState) -> int:
	.integrate_forces(state)
	if entity.can_move:
		apply_movement(entity, state, 1.5)
		if entity.controllable and Input.is_action_pressed("action_main") and can_jump:
			var multiplier
			if jump_combo >= 3:
				multiplier = 0.8
			if jump_combo >= 2:
				multiplier = 0.65
			else:
				multiplier = 0.5
			state.apply_central_impulse(multiplier * entity.global_transform.basis.y)
		state.apply_central_impulse((entity.jump / 1.2) * entity.global_transform.basis.y)
	return State.NULL

func on_timeout() -> void:
	can_jump = false

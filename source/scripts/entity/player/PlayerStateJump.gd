extends PlayerStateMain

var can_jump : bool

func enter() -> void:
	print("Player State: JUMP")
	can_jump = true
	var jump_timer = Timer.new()
	jump_timer.set_wait_time(0.2)
	jump_timer.one_shot = true
	jump_timer.connect("timeout", self, "on_timeout")
	add_child(jump_timer)
	jump_timer.start()
	entity.animator.set_speed_scale(1)
	entity.animator.play("PlayerJumpDefault")

func input(_event: InputEvent) -> int:
	if Input.is_action_just_pressed("action_defense"):
		if entity.input == Vector3.ZERO:
			return State.HIDE
		else:
			return State.DODG
	return State.NULL

func physics_process(delta: float) -> int:
	.physics_process(delta)
	if dodge_roll():
		AudioPlayer.play_pos_sfx(AudioPlayer.sfx_snail_shell_in, entity.global_translation)
		return State.DODG
		#entity.velocity.y += (entity.jump * 50) * delta / 2
#	else:
#		return State.FALL
	if !can_jump:
		return State.FALL
	return State.NULL

func integrate_forces(state) -> int:
	.integrate_forces(state)
	apply_movement()
	if entity.is_active_player and Input.is_action_pressed("action_main") and entity.ray_down.is_colliding() and can_jump:
		entity.apply_central_impulse(entity.jump * entity.global_transform.basis.y)
	return State.NULL

func on_timeout():
	can_jump = false

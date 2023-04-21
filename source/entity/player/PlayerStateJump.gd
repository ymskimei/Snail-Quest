extends PlayerStateMain

var can_jump : bool

func enter() -> void:
	print("Player State: JUMP")
	can_jump = true
	var jump_timer = Timer.new()
	jump_timer.set_wait_time(1)
	jump_timer.one_shot = true
	jump_timer.connect("timeout", self, "on_timeout")
	add_child(jump_timer)
	jump_timer.start()
	entity.animator.set_speed_scale(1)
	entity.animator.play("PlayerJumpDefault")
	entity.apply_impulse(Vector3(), Vector3(0, 10, 0))
	
func input(_event: InputEvent) -> int:
	if Input.is_action_just_pressed("action_defense"):
		if entity.input == Vector3.ZERO:
			return State.HIDE
		else:
			return State.DODG
	return State.NULL

func physics_process(delta) -> int:
	.physics_process(delta)
	MathHelper.slerp_look_at(entity, entity.transform.origin + Vector3(entity.velocity.x, 0, entity.velocity.z), 0.55)
	#apply_movement(delta, true, deg2rad(45))
	apply_movement()
	#apply_gravity(delta)
	if dodge_roll():
		AudioPlayer.play_sfx(AudioPlayer.sfx_snail_shell_in)
		return State.DODG
	if Input.is_action_pressed("action_main") and can_jump:
		entity.snap_vector = Vector3.ZERO
		
	else:
		return State.FALL
	if entity.velocity.y < 0:
		return State.FALL
	return State.NULL

func integrate_forces(state) -> int:
	.integrate_forces(state)
	return State.NULL

func on_timeout():
	print("ding in jump timer")
	can_jump = false

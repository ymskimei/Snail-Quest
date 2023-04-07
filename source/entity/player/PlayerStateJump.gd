extends PlayerStateMain

var can_jump : bool

func enter() -> void:
	print("Player State: JUMP")
	can_jump = true
	var jump_timer = Timer.new()
	jump_timer.set_wait_time(0.17)
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
	apply_facing(0.9)
	apply_movement(delta, true, deg2rad(45))
	if dodge_roll():
		return State.DODG
	if Input.is_action_pressed("action_main") and can_jump:
		entity.snap_vector = Vector3.ZERO
		entity.velocity.y += entity.jump
	else:
		return State.FALL
	if entity.velocity.y < 0:
		return State.FALL
	return State.NULL

func on_timeout():
	can_jump = false

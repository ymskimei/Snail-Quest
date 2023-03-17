extends PlayerStateMain

var can_jump : bool

func enter() -> void:
	print("Player State: JUMP")
	can_jump = true
	var jump_timer = Timer.new()
	jump_timer.set_wait_time(0.15)
	jump_timer.one_shot = true
	jump_timer.connect("timeout", self, "on_timeout")
	add_child(jump_timer)
	jump_timer.start()

func physics_process(delta: float) -> int:
	.physics_process(delta)
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

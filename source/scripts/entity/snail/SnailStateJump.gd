extends SnailStateMain

var can_jump: bool
var jump_timer: Timer

func enter() -> void:
	print("Snail State: JUMP")
	can_jump = true
	jump_timer = Timer.new()
	jump_timer.set_wait_time(0.3)
	jump_timer.one_shot = true
	jump_timer.connect("timeout", self, "on_timeout")
	add_child(jump_timer)
	jump_timer.start()
	combo_check()

func unhandled_input(event: InputEvent) -> int:
	if event.is_action_pressed("action_defense"):
		if entity.input == Vector3.ZERO:
			return State.HIDE
		else:
			return State.DODG
	if event.is_action_released("action_main"):
		if is_instance_valid(jump_timer):
			jump_timer.set_wait_time(0.15)
			jump_timer.start()
	return State.NULL

func physics_process(delta: float) -> int:
	.physics_process(delta)
	if !can_jump:
		return State.FALL
	return State.NULL

func integrate_forces(state: PhysicsDirectBodyState) -> int:
	.integrate_forces(state)
	apply_movement(state, 0.5)
	state.add_central_force(lerp(72, 10, 0.2) * entity.global_transform.basis.y)
	return State.NULL

func combo_check():
	if jump_combo >= 2:
		entity.anim.play("SnailFlip")
	elif jump_combo == 1:
		jump_combo += 1
		entity.anim.play("SnailJump")
		jump_combo_timer.start()
	else:
		jump_combo += 1
		entity.anim.play("SnailJump")

func on_timeout() -> void:
	can_jump = false
	jump_timer.queue_free()

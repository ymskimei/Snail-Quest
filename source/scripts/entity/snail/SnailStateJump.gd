extends SnailStateMain

var can_jump: bool = false
var jump_timer: Timer = null

func enter() -> void:
	print("Snail State: JUMP")
	entity.attached_to_location = false
	can_jump = true
	jump_timer = Timer.new()
	jump_timer.set_wait_time(0.2)
	jump_timer.one_shot = true
	jump_timer.connect("timeout", Callable(self, "on_timeout"))
	add_child(jump_timer)
	jump_timer.start()
	combo_check()

func states_unhandled_input(event: InputEvent) -> int:
	if event.is_action_pressed("action_defense"):
		if input == Vector3.ZERO:
			return State.HIDE
		else:
			return State.DODG
	if event.is_action_pressed("action_main"):
		entity.jump_memory()
	if event.is_action_released("action_main"):
		if is_instance_valid(jump_timer):
			jump_timer.set_wait_time(0.075)
			jump_timer.start()
	return State.NULL

func states_physics_process(delta: float) -> int:
	super.states_physics_process(delta)
	if entity.ledge_usable and !entity.ray_front_top.is_colliding() and entity.ray_front_bottom.is_colliding():
		if is_instance_valid(entity.ray_front_top.get_collider()):
			if !entity.ray_front_top.get_collider().is_in_group.attachable:
				return State.HANG
	if !can_jump:
		return State.FALL
	return State.NULL

func states_integrate_forces(state: PhysicsDirectBodyState3D) -> int:
	super.states_integrate_forces(state)
	apply_movement(state, 0.5)
	state.apply_central_force(lerp(65, 10, 0.6) * entity.global_transform.basis.y)
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

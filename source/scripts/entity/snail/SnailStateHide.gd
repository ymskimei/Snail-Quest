extends SnailStateMain

func enter() -> void:
	print("Snail State: HIDE")
	entity.anim.play("SnailHide")
	await entity.anim.animation_finished
	entity.anim.play("SnailHidden")
	entity.in_shell = true

func states_input(event: InputEvent) -> int:
	if event.is_action_released("action_defense"):
		return State.IDLE
	if event.is_action_pressed("action_main") and !shell_jumped:
		shell_jumped = true
		return State.JUMP
	return State.NULL

func states_physics_process(delta: float) -> int:
	super.states_physics_process(delta)
	if direction != Vector3.ZERO and is_on_floor():
		return State.ROLL
	return State.NULL

func states_integrate_forces(state: PhysicsDirectBodyState3D) -> int:
	super.states_integrate_forces(state)
	return State.NULL

func left_shell() -> void:
	entity.anim.play("SnailUnhide")
	await entity.anim.animation_finished

func exit() -> void:
	entity.in_shell = false

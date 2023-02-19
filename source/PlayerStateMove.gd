extends PlayerStateMain

func enter() -> void:
	print("State: MOVE")

func input(event: InputEvent) -> int:
	if Input.is_action_just_pressed("ui_select"):
		return State.JUMP
	return State.NULL

func physics_process(delta: float) -> int:
	.physics_process(delta)
	apply_movement(direction, delta)
	if !player.is_on_floor():
		return State.FALL
	if input_vector == Vector3.ZERO:
		return State.IDLE
	return State.NULL

extends PlayerStateMain

func enter() -> void:
	print("Player State: MOVE")

func input(_event: InputEvent) -> int:
	if !player.can_interact and Input.is_action_just_pressed("action_main") and player.is_on_floor():
		return State.JUMP
	return State.NULL

func physics_process(delta: float) -> int:
	.physics_process(delta)
	if !player.is_on_floor():
		return State.FALL
	if player.input == Vector3.ZERO:
		return State.IDLE
	return State.NULL

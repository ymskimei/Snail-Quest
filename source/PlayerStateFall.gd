extends PlayerStateMain

func enter() -> void:
	print("Player State: FALL")

func physics_process(delta: float) -> int:
	.physics_process(delta)
	if player.is_on_floor():
		if input_vector != Vector3.ZERO:
			return State.MOVE
		else:
			return State.IDLE
	return State.NULL

extends PlayerStateMain

func enter() -> void:
	print("Player State: JUMP")
	player.snap_vector = Vector3.ZERO
	player.velocity.y = player.jump

func physics_process(delta: float) -> int:
	.physics_process(delta)
	if player.is_on_floor():
		if player.input:
			return State.MOVE
		else:
			return State.IDLE
	if player.velocity.y < 0:
		return State.FALL
	return State.NULL

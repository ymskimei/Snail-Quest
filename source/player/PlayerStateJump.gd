extends PlayerStateMain

func enter() -> void:
	print("Player State: JUMP")
	player.snap_vector = Vector3.ZERO
	player.velocity.y = jump_power
	print(player.velocity.y)

func physics_process(delta: float) -> int:
	.physics_process(delta)
	if player.is_on_floor():
#		if input_vector:
#			return State.MOVE
#		else:
		return State.IDLE
	if player.velocity.y < 0:
		return State.FALL
	return State.NULL

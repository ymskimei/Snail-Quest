extends PlayerStateMain

func enter() -> void:
	print("State: JUMP")
	snap_vector = Vector3.ZERO
	velocity.y = jump_power
	print(velocity.y)

func physics_process(delta: float) -> int:
	.physics_process(delta)
	#velocity.y += gravity
	if player.is_on_floor():
#		if input_vector:
#			return State.MOVE
#		else:
			return State.IDLE
	if velocity.y > 0:
		return State.FALL
	return State.NULL

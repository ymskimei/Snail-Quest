extends PlayerStateMain

func enter() -> void:
	print("Player State: JUMP")
	entity.snap_vector = Vector3.ZERO
	entity.velocity.y = entity.jump

func physics_process(delta: float) -> int:
	.physics_process(delta)
	if entity.is_on_floor():
		if entity.input:
			return State.MOVE
		else:
			return State.IDLE
	if entity.velocity.y < 0:
		return State.FALL
	return State.NULL

extends PlayerStateMain

func enter() -> void:
	print("Player State: FALL")

func physics_process(delta: float) -> int:
	.physics_process(delta)
	entity.velocity.x += entity.velocity.x * -2 * delta
	entity.velocity.z += entity.velocity.z * -2 * delta
	if entity.is_on_floor():
		if entity.input != Vector3.ZERO:
			return State.MOVE
		else:
			return State.IDLE
	return State.NULL

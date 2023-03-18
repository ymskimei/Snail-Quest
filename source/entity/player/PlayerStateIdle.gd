extends PlayerStateMain

func enter() -> void:
	print("Player State: IDLE")
	entity.velocity.x = 0
	entity.velocity.z = 0

func input(_event: InputEvent) -> int:
	if !entity.can_interact and Input.is_action_just_pressed("action_main") and entity.is_on_floor():
		return State.JUMP
	return State.NULL

func physics_process(delta: float) -> int:
	.physics_process(delta)
	if entity.input != Vector3.ZERO and entity.is_on_floor():
		return State.MOVE
	elif !entity.is_on_floor():
		return State.FALL
	return State.NULL

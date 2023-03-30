extends PlayerStateMain

func enter() -> void:
	print("Player State: MOVE")

func input(_event: InputEvent) -> int:
	if !entity.can_interact and Input.is_action_just_pressed("action_main") and entity.is_on_floor():
		return State.JUMP
	return State.NULL

func physics_process(delta: float) -> int:
	.physics_process(delta)
	entity.snap_vector = Vector3.DOWN
	if !entity.is_on_floor():
		return State.FALL
	if entity.input == Vector3.ZERO:
		return State.IDLE
	return State.NULL

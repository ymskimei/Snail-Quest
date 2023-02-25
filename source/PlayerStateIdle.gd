extends PlayerStateMain

func enter() -> void:
	print("Player State: IDLE")

func input(_event: InputEvent) -> int:
	if Input.is_action_just_pressed("ui_select") and player.is_on_floor():
		return State.JUMP
	return State.NULL

func physics_process(delta: float) -> int:
	.physics_process(delta)
	if input_vector != Vector3.ZERO and player.is_on_floor():
		return State.MOVE
	elif !player.is_on_floor():
		return State.FALL
	return State.NULL

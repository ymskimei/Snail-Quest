extends PlayerStateMain

func enter() -> void:
	print("Player State: IDLE")
	player.velocity.x = 0
	player.velocity.z = 0

func input(_event: InputEvent) -> int:
	if Input.is_action_just_pressed("ui_select") and player.is_on_floor():
		return State.JUMP
	return State.NULL

func physics_process(delta: float) -> int:
	.physics_process(delta)
	apply_facing()
	if input_vector != Vector3.ZERO and player.is_on_floor():
		if Input.is_action_pressed("cam_lock"):
			return State.TARGET
		else:
			return State.MOVE
	elif !player.is_on_floor():
		return State.FALL
	return State.NULL

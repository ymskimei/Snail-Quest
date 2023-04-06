extends PlayerStateMain

func enter() -> void:
	print("Player State: IDLE")
	entity.velocity.x = 0
	entity.velocity.z = 0
	entity.animator.set_speed_scale(1)
	entity.animator.play("Idle")

func input(_event: InputEvent) -> int:
	if !entity.can_interact and Input.is_action_just_pressed("action_main") and entity.is_on_floor():
		return State.JUMP
	if Input.is_action_just_pressed("action_defense") and entity.is_on_floor():
		return State.HIDE
	return State.NULL

func physics_process(delta: float) -> int:
	.physics_process(delta)
	entity.snap_vector = Vector3.DOWN
	if entity.input != Vector3.ZERO and entity.is_on_floor():
		return State.MOVE
	elif !entity.is_on_floor():
		return State.FALL
	return State.NULL

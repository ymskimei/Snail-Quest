extends PlayerStateMain

export var air_friction = -3.5

func enter() -> void:
	print("Player State: FALL")
	yield(entity.animator, "animation_finished")
	entity.animator.set_speed_scale(1)
	entity.animator.play("Fall")

func input(_event: InputEvent) -> int:
	if Input.is_action_just_pressed("action_defense"):
		return State.ROLL
	return State.NULL

func physics_process(delta: float) -> int:
	.physics_process(delta)
	apply_facing(0.9)
	entity.snap_vector = Vector3.DOWN
	if entity.input == Vector3.ZERO:
		entity.velocity.x += entity.velocity.x * air_friction * delta
		entity.velocity.z += entity.velocity.z * air_friction * delta
	else:
		entity.velocity.x += entity.velocity.x * delta
		entity.velocity.z += entity.velocity.z * delta
	if entity.is_on_floor():
		if entity.input != Vector3.ZERO:
			return State.MOVE
		else:
			return State.IDLE
	return State.NULL

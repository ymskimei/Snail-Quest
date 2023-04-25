extends PlayerStateMain

export var air_friction = -3.5

func enter() -> void:
	print("Player State: FALL")
	yield(entity.animator, "animation_finished")
	entity.animator.set_speed_scale(1)
	entity.animator.play("PlayerFallDefault")

func input(_event: InputEvent) -> int:
	if Input.is_action_just_pressed("action_defense"):
		AudioPlayer.play_sfx(AudioPlayer.sfx_snail_shell_in)
		if entity.input == Vector3.ZERO:
			return State.HIDE
		else:
			return State.DODG
	needle()
	mallet()
	return State.NULL

func physics_process(delta: float) -> int:
	.physics_process(delta)
	MathHelper.slerp_look_at(entity, entity.transform.origin + Vector3(entity.velocity.x, 0, entity.velocity.z), 0.4)
	apply_movement(delta, true, deg2rad(45))
	apply_gravity(delta)
	if dodge_roll():
		AudioPlayer.play_sfx(AudioPlayer.sfx_snail_shell_in)
		return State.DODG
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

func exit() -> void:
	entity.speed = entity.resource.speed

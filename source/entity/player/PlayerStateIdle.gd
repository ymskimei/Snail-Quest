extends PlayerStateMain

func enter() -> void:
	print("Player State: IDLE")
	entity.speed = entity.resource.speed
	entity.velocity.x = 0
	entity.velocity.z = 0
	entity.animator.set_speed_scale(1)
	entity.animator.play("PlayerIdleDefault")

func input(_event: InputEvent) -> int:
	if !entity.can_interact and Input.is_action_just_pressed("action_main") and entity.is_on_floor():
		return State.JUMP
	if Input.is_action_just_pressed("action_defense") and entity.is_on_floor():
		entity.animator.play("PlayerTuckDefault")
		AudioPlayer.play_sfx(AudioPlayer.sfx_snail_shell_in)
		return State.HIDE
	needle_swing()
	mallet_slam()
	if entity.targeting:
		needle_aiming()
	return State.NULL

func physics_process(delta: float) -> int:
	.physics_process(delta)
	apply_movement(delta, true, deg2rad(45))
	apply_gravity(delta)
	if dodge_roll():
		AudioPlayer.play_sfx(AudioPlayer.sfx_snail_shell_in)
		return State.DODG
	entity.snap_vector = Vector3.DOWN
	if entity.input != Vector3.ZERO and entity.is_on_floor():
		return State.MOVE
	elif !entity.is_on_floor():
		return State.FALL
	return State.NULL

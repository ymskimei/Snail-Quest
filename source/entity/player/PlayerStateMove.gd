extends PlayerStateMain

func enter() -> void:
	print("Player State: MOVE")
	entity.speed = entity.resource.speed
	entity.animator.set_speed_scale(1)
	entity.animator.play("PlayerMoveDefault")
#	var id = entity.skeleton.find_bone("BoneEyeballMainController")
#	print("Bone ID: ", id)

func input(_event: InputEvent) -> int:
	if !entity.can_interact and Input.is_action_just_pressed("action_main") and entity.is_on_floor():
		return State.JUMP
	if Input.is_action_just_pressed("action_defense"):
		AudioPlayer.play_sfx(AudioPlayer.sfx_snail_shell_in)
		return State.DODG
	return State.NULL

func physics_process(delta: float) -> int:
	.physics_process(delta)
	apply_facing(0.65)
	apply_movement(delta, true, deg2rad(180))
	if dodge_roll():
		AudioPlayer.play_sfx(AudioPlayer.sfx_snail_shell_in)
		return State.DODG
	entity.snap_vector = Vector3.DOWN
	var anim_speed = clamp((abs(entity.velocity.x) + abs(entity.velocity.z)), 0, 2)
	entity.animator.set_speed_scale(anim_speed)
	if !entity.is_on_floor():
		return State.FALL
	if entity.input == Vector3.ZERO:
		return State.IDLE
	return State.NULL

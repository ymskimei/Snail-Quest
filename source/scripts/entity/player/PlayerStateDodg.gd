extends PlayerStateMain

var dodge_complete : bool

func enter() -> void:
	print("Player State: DODG")
	dodge_complete = false
	dodge_timer()
	entity.animator.set_speed_scale(1)
	entity.animator.play("PlayerTuckDefault")
	yield(entity.animator, "animation_finished")
	entity.speed *= 2
	if entity.targeting:
		if entity.input.x > 0:
			entity.animator.play("PlayerRollLeft")
		elif entity.input.x < 0:
			entity.animator.play("PlayerRollRight")
		elif entity.input.z > 0:
			entity.animator.play("PlayerRollFront")
		elif entity.input.z < 0:
			entity.animator.play("PlayerRollBack")
		else:
			dodge_complete = true
	else:
		entity.animator.play("PlayerRollFront")
	entity.in_shell = true

func physics_process(delta: float) -> int:
	.physics_process(delta)
	#apply_facing()
	apply_movement(delta)
	#apply_gravity(delta)
	entity.snap_vector = Vector3.DOWN
	if entity.is_active_player and Input.is_action_just_pressed("action_main") and !shell_jumped:
		AudioPlayer.play_pos_sfx(AudioPlayer.sfx_snail_shell_out, entity.global_translation)
		shell_jumped = true
		return State.JUMP
	if dodge_complete:
		if entity.is_active_player and Input.is_action_pressed("action_defense"):
			return State.HIDE
		else:
			AudioPlayer.play_pos_sfx(AudioPlayer.sfx_snail_shell_out, entity.global_translation)
			return State.IDLE
#	if entity.is_colliding():
#		Input.start_joy_vibration(0, 1, 1, 0.5)
#		on_dodge_timer()
	return State.NULL

func integrate_forces(state) -> int:
	.integrate_forces(state)
	return State.NULL

func dodge_timer():
	var timer = Timer.new()
	timer.set_one_shot(true)
	timer.set_wait_time(0.65)
	timer.connect("timeout", self, "on_dodge_timer")
	add_child(timer)
	timer.start()

func on_dodge_timer():
	dodge_complete = true
	entity.in_shell = false

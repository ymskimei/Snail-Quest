extends SnailStateMain

var dodge_complete: bool = false

func enter() -> void:
	print("Snail State: DODG")
	dodge_timer()
	entity.animator.set_speed_scale(1)
	entity.animator.play("SnailHide")
	yield(entity.animator, "animation_finished")
	entity.speed *= 2
	if entity.targeting:
		if entity.input.x > 0:
			entity.animator.play("SnailRollFront")
		elif entity.input.x < 0:
			entity.animator.play("SnailRollFront")
		elif entity.input.z > 0:
			entity.animator.play("SnailRollFront")
		elif entity.input.z < 0:
			entity.animator.play("SnailRollBack")
		else:
			dodge_complete = true
	else:
		entity.animator.play("SnailRollFront")
	entity.in_shell = true

func physics_process(delta: float) -> int:
	.physics_process(delta)
	if entity.controllable and Input.is_action_just_pressed("action_main") and !shell_jumped:
		AudioPlayer.play_pos_sfx(AudioPlayer.sfx_snail_shell_out, entity.global_translation)
		shell_jumped = true
		return State.JUMP
	if dodge_complete:
		if entity.controllable and Input.is_action_pressed("action_defense"):
			return State.HIDE
		else:
			AudioPlayer.play_pos_sfx(AudioPlayer.sfx_snail_shell_out, entity.global_translation)
			return State.IDLE
#	if entity.is_colliding():
#		Input.start_joy_vibration(0, 1, 1, 0.5)
#		on_dodge_timer()
	return State.NULL

func integrate_forces(state: PhysicsDirectBodyState) -> int:
	.integrate_forces(state)
	apply_movement(entity, state, 2.05)
	return State.NULL

func dodge_timer() -> void:
	var timer = Timer.new()
	timer.set_one_shot(true)
	timer.set_wait_time(0.65)
	timer.connect("timeout", self, "on_dodge_timer")
	add_child(timer)
	timer.start()

func on_dodge_timer() -> void:
	dodge_complete = true
	entity.in_shell = false

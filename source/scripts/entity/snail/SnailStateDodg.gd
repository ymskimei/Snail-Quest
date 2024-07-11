extends SnailStateMain

var dodge_complete: bool = false

func enter() -> void:
	print("Snail State: DODG")
	#AudioPlayer.play_pos_sfx(AudioPlayer.sfx_snail_shell_in, entity.global_translation)
	dodge_timer()
	entity.anim.play("SnailHide")
	yield(entity.anim, "animation_finished")
	if entity.targeting:
		if entity.input.x > 0:
			entity.anim.play("SnailRollFront")
		elif entity.input.x < 0:
			entity.anim.play("SnailRollFront")
		elif entity.input.z > 0:
			entity.anim.play("SnailRollFront")
		elif entity.input.z < 0:
			entity.anim.play("SnailRollBack")
		else:
			dodge_complete = true
	else:
		entity.anim.play("SnailRollFront")
	entity.in_shell = true

func unhandled_input(event: InputEvent) -> int:
	if event.is_action_pressed("action_main") and !shell_jumped:
		shell_jumped = true
		return State.JUMP
	return State.NULL

func physics_process(delta: float) -> int:
	.physics_process(delta)
	if dodge_complete:
		if Input.is_action_pressed("action_defense"):
			return State.HIDE
		else:
			return State.IDLE
	#if entity.is_colliding():
		#Device.start_joy_vibration(0, 1, 1, 0.5)
		#on_dodge_timer()
	return State.NULL

func integrate_forces(state: PhysicsDirectBodyState) -> int:
	.integrate_forces(state)
	apply_movement(state, 3.0)
	return State.NULL

func dodge_timer() -> void:
	var timer = Timer.new()
	timer.set_one_shot(true)
	timer.set_wait_time(0.65)
	timer.connect("timeout", self, "on_dodge_timer")
	add_child(timer)
	timer.start()

func on_dodge_timer() -> void:
	#AudioPlayer.play_pos_sfx(AudioPlayer.sfx_snail_shell_out, entity.global_translation)
	dodge_complete = true
	entity.in_shell = false

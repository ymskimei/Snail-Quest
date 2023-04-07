extends PlayerStateMain

var dodge_complete : bool

func enter() -> void:
	print("Player State: DODG")
	dodge_complete = false
	dodge_timer()
	entity.animator.set_speed_scale(1)
	entity.animator.play("PlayerTuckDefault")
	yield(entity.animator, "animation_finished")
	entity.speed *= 1.8
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
		entity.animator.play("PlayerRollFront")

func physics_process(delta: float) -> int:
	.physics_process(delta)
	apply_facing(0.3)
	apply_movement(delta, true, deg2rad(45))
	entity.snap_vector = Vector3.DOWN
	if Input.is_action_just_pressed("action_main"):
		AudioPlayer.play_sfx(AudioPlayer.sfx_snail_shell_out)
		return State.JUMP
	if dodge_complete:
		if Input.is_action_pressed("action_defense"):
			return State.HIDE
		else:
			AudioPlayer.play_sfx(AudioPlayer.sfx_snail_shell_out)
			return State.IDLE
	return State.NULL

func dodge_timer():
	var timer = Timer.new()
	timer.set_one_shot(true)
	timer.set_wait_time(0.65)
	timer.connect("timeout", self, "on_dodge_timer")
	add_child(timer)
	timer.start()

func on_dodge_timer():
	print("ding")
	dodge_complete = true

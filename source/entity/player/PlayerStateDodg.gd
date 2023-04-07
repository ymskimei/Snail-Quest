extends PlayerStateMain

var dodge_complete : bool

func enter() -> void:
	print("Player State: DODG")
	AudioPlayer.play_sfx(AudioPlayer.sfx_snail_shell_in)
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

func input(_event: InputEvent) -> int:
	if Input.is_action_just_released("ui_left") or Input.is_action_just_released("ui_right") or Input.is_action_just_released("ui_up") or Input.is_action_just_released("ui_down	"):
		return State.IDLE
	return State.NULL

func physics_process(delta: float) -> int:
	.physics_process(delta)
	apply_facing(0.3)
	apply_movement(delta, true, deg2rad(45))
	entity.snap_vector = Vector3.DOWN
	if Input.is_action_just_pressed("action_main"):
		return State.JUMP
	if dodge_complete:
		return State.IDLE
	return State.NULL

func dodge_timer():
	var timer = Timer.new()
	timer.set_one_shot(true)
	timer.set_wait_time(0.6)
	timer.connect("timeout", self, "on_dodge_timer")
	add_child(timer)
	timer.start()

func on_dodge_timer():
	print("ding")
	dodge_complete = true

func exit() -> void:
	AudioPlayer.play_sfx(AudioPlayer.sfx_snail_shell_out)

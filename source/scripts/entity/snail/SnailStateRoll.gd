extends SnailStateMain

var boost_timer: Timer = Timer.new()

var slide_timer: Timer = Timer.new()

func enter() -> void:
	print("Snail State: ROLL")
	boost_timer = Timer.new()
	boost_timer.set_wait_time(5.5)
	boost_timer.one_shot = true
	boost_timer.connect("timeout", self, "_on_boost_timeout")
	add_child(boost_timer)
	boost_timer.start()
	entity.anim_states.travel("SnailRoll")

func unhandled_input(event: InputEvent) -> int:
	if is_on_surface():
		if event.is_action_pressed(Device.action_main):
			return State.JUMP
		if event.is_action_released(Device.trigger_right):
			return State.MOVE
	return State.NULL

func physics_process(delta: float) -> int:
	set_gravity(delta)
	set_rotation(delta)

	if entity.boosting and entity.direction.length() >= 1.8:
		if entity.move_momentum < entity.max_momentum:
			entity.move_momentum += 0.35 * delta

	if entity.jump_in_memory:
		return State.JUMP

	set_movement(delta * (1.6 + entity.move_momentum))
	entity.anim_tree.set("parameters/SnailRoll/TimeScale/scale", entity.direction.length() * 1.75)

	if !is_on_surface(true):
		entity.can_late_jump = true
		return State.FALL
	return State.NULL

func _on_boost_timeout() -> void:
	entity.boosting = true

func exit() -> void:
	entity.anim.set_speed_scale(1.0)
	boost_timer.stop()

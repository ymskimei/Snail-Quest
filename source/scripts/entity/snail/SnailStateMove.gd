extends SnailStateMain

var boost_timer: Timer = Timer.new()
#var exhaust_timer: Timer = Timer.new()

var slide_timer: Timer = Timer.new()

var prev_dir: Vector3 = Vector3.ZERO
var can_slide: bool = false

func enter() -> void:
	print("Snail State: MOVE")
	boost_timer = Timer.new()
	boost_timer.set_wait_time(5.5)
	boost_timer.one_shot = true
	boost_timer.connect("timeout", self, "_on_boost_timeout")
	add_child(boost_timer)
	boost_timer.start()
	entity.anim_states.travel("SnailMove")

#	if entity.temporary_exhaustion:
#		exhaust_timer = Timer.new()
#		exhaust_timer.set_wait_time(2)
#		exhaust_timer.one_shot = true
#		exhaust_timer.connect("timeout", self, "_on_exhaust_timeout")
#		add_child(exhaust_timer)
#		exhaust_timer.start()

	slide_timer = Timer.new()
	slide_timer.set_wait_time(0.05)
	slide_timer.one_shot = true
	slide_timer.connect("timeout", self, "_on_slide_timeout")
	add_child(slide_timer)

func unhandled_input(event: InputEvent) -> int:
	if is_on_surface():
		if event.is_action_pressed(Device.action_main):
			return State.JUMP
		if event.is_action_pressed(Device.trigger_right):
			return State.ROLL
	if event.is_action_pressed(Device.action_alt):
		return State.SPIN
	return State.NULL

func physics_process(delta: float) -> int:
	set_gravity(delta)
	set_rotation(delta)
	boost_momentum()

	if entity.boosting and entity.direction.length() >= 1.8:
		if entity.move_momentum < entity.max_momentum:
			entity.move_momentum += 0.35 * delta

	if entity.jump_in_memory or entity.boost_momentum != Vector3.ZERO:
		return State.JUMP

#		if abs(entity.direction.length()) <= 1.8:
#			prev_dir = entity.direction
#			slide_timer.start()

#	else:
#		if entity.move_momentum > 1.0:
#			entity.move_momentum -= 7 * delta

#	if entity.temporary_exhaustion:
#		set_movement(delta * 0.75)
#	else:
	set_movement(delta * (1.0 + entity.move_momentum))
	entity.anim_tree.set("parameters/SnailMove/TimeScale/scale", entity.direction.length())
	if entity.direction.length() <= 0.1:
		return State.IDLE

#	if can_slide:
#		return State.SLID

	if !is_on_surface(true):
		entity.can_late_jump = true
		return State.FALL
	return State.NULL

#func _on_exhaust_timeout() -> void:
#	entity.temporary_exhaustion = false

func _on_boost_timeout() -> void:
	entity.boosting = true

func _on_slide_timeout() -> void:
	if abs(prev_dir.length() - entity.direction.length()) >= 0.4:
		can_slide = true

func exit() -> void:
	entity.anim.set_speed_scale(1.0)
	boost_timer.queue_free()
	slide_timer.queue_free()
	can_slide = false

extends SnailState

var boost_timer: Timer = Timer.new()

var slide_timer: Timer = Timer.new()

var prev_dir: Vector3 = Vector3.ZERO
var can_slide: bool = false

func enter() -> void:
	print_state_name(STATE_NAMES, State.MOVE)

	entity.anim_states.travel("SnailMove")

	entity.move_momentum = 0

	boost_timer = Timer.new()
	boost_timer.set_wait_time(5.5)
	boost_timer.one_shot = true
	boost_timer.connect("timeout", self, "_on_boost_timeout")
	add_child(boost_timer)
	boost_timer.start()

	slide_timer = Timer.new()
	slide_timer.set_wait_time(0.05)
	slide_timer.one_shot = true
	slide_timer.connect("timeout", self, "_on_slide_timeout")
	add_child(slide_timer)

	prev_dir = entity.facing_direction

func unhandled_input(event: InputEvent) -> int:
	if is_on_surface():
		if event.is_action_pressed(Device.action_main) and !entity.can_interact:
			return State.JUMP

		if event.is_action_pressed(Device.trigger_right):
			return State.ROLL

	if event.is_action_pressed(Device.action_alt):
		return State.SPIN

	return State.NULL

func physics_process(delta: float) -> int:
	if entity.boosting and entity.input_direction.length() > 0.85:
		if entity.move_momentum < entity.max_momentum:
			entity.move_momentum += 0.5 * delta

	if entity.jump_in_memory or entity.boost_direction.length() > 0.1:
		return State.JUMP

	if entity.is_submerged():
		set_movement(delta, 1.1 + entity.move_momentum, 5.0)
	else:
		set_movement(delta, 1.0 + entity.move_momentum)

	entity.anim_tree.set("parameters/SnailMove/TimeScale/scale", entity.input_direction.length())
	entity.anim_tree.set("parameters/SnailMove/Blend2/blend_amount", entity.input_direction.length())

	var angle: int = 0
	var cur_dir = entity.facing_direction
	var rot_diff = cur_dir - prev_dir
	if abs(rot_diff.y) > 0.1:
		if rot_diff.y < 0:
			angle = 1
		else:
			angle = -1
	prev_dir = cur_dir

	#entity.anim_tree.set("parameters/SnailMove/Blend3/blend_amount", lerp(0, angle, 20 * delta))

	if entity.move_direction.length() < 0.1 or entity.interacting:
		return State.IDLE

	if !is_on_surface():
		entity.can_late_jump = true
		return State.FALL

	return State.NULL

func _on_boost_timeout() -> void:
	entity.boosting = true

func _on_slide_timeout() -> void:
	if abs(prev_dir.length() - entity.move_direction.length()) >= 0.4:
		can_slide = true

func exit() -> void:
	entity.anim.set_speed_scale(1.0)
	boost_timer.queue_free()
	slide_timer.queue_free()
	can_slide = false

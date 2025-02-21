extends SnailState

var fling_timer: Timer = Timer.new()

var stretch_amount: float = 0
var flinging: bool = false
var end_fling: bool = false

func enter() -> void:
	print_state_name(STATE_NAMES, State.STCK)
	fling_timer.set_wait_time(0.5)
	fling_timer.one_shot = true
	fling_timer.connect("timeout", self, "_on_fling_timeout")
	add_child(fling_timer)

	entity.anim_states.travel("SnailStretch")

	entity.move_momentum = 0
	entity.boosting = false

func unhandled_input(event: InputEvent) -> int:
	if event.is_action_released(Device.action_main):
		entity.anim_states.travel("SnailIdle")
		flinging = true
		fling_timer.start()
	return State.NULL

func physics_process(delta: float) -> int:
	#set_movement(delta, 0.0)

	var amount: float = 0.0
	if entity.input_direction.y < 0.0:
		amount += abs(entity.input_direction.y) * 10 * delta
	else:
		amount -= abs(entity.input_direction.y) * delta
	print(amount)
	entity.anim_tree.set("parameters/SnailStretch/Blend3/blend_amount", amount)

	if flinging:
		set_movement(delta, 1.6 + (entity.move_momentum * 0.5), 0.6)
		entity.jump_strength = 24 * entity.fall_momentum

	if end_fling:
		return State.IDLE

	if !is_on_surface():
		return State.FALL

	return State.NULL

func _on_fling_timeout() -> void:
	end_fling = true

func exit() -> void:
	flinging = false
	end_fling = false
	stretch_amount = 0

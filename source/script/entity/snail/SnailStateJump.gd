extends SnailState

var jumping: bool = true
var jump_timer: Timer = Timer.new()

func enter() -> void:
	print_state_name(STATE_NAMES, State.JUMP)

	entity.anim_states.travel("SnailJump")
	entity.jump_in_memory = false
	entity.fall_momentum = 1
	entity.play_sound_bounce()
	jumping = true

	jump_timer = Timer.new()
	jump_timer.set_wait_time(0.1)
	jump_timer.one_shot = true
	jump_timer.connect("timeout", self, "_on_jump_timeout")
	add_child(jump_timer)
	jump_timer.start()

func unhandled_input(event: InputEvent) -> int:
	if entity.is_submerged() and event.is_action_pressed(Device.action_main):
		return State.JUMP

	if event.is_action_released(Device.action_main):
		jumping = false

	if event.is_action_pressed(Device.trigger_right):
			return State.GPND

	if event.is_action_pressed(Device.action_alt):
		return State.SPIN

	return State.NULL

func physics_process(delta: float) -> int:
	set_movement(delta, 1.6 + (entity.move_momentum * 0.5), 0.6)

	entity.jump_strength = 24 * entity.fall_momentum

	if !jumping:
		entity.fall_momentum -= 7 * delta
	if entity.fall_momentum <= 0:

		return State.FALL
	return State.NULL

func _on_jump_timeout() -> void:
	jumping = false

func exit() -> void:
	jump_timer.queue_free()


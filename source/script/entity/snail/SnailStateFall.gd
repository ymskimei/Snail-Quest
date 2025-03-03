extends SnailState

var fall_sound: AudioStreamPlayer3D 

var can_dive: bool = false

var late_jump_timer: Timer = Timer.new()
var stored_jump_timer: Timer = Timer.new()
var dive_timer: Timer = Timer.new()

func enter() -> void:
	print_state_name(STATE_NAMES, State.FALL)

	if entity.was_just_in_shell:
		entity.anim_states.travel("SnailHidden")
		entity.was_just_in_shell = false

	can_dive = false
	entity.fall_momentum = 0

	late_jump_timer = Timer.new()
	late_jump_timer.set_wait_time(0.135)
	late_jump_timer.one_shot = true
	late_jump_timer.connect("timeout", self, "_late_jump_timeout")
	add_child(late_jump_timer)
	late_jump_timer.start()

	stored_jump_timer = Timer.new()
	stored_jump_timer.set_wait_time(0.115)
	stored_jump_timer.one_shot = true
	stored_jump_timer.connect("timeout", self, "_stored_jump_timeout")
	add_child(stored_jump_timer)

	dive_timer = Timer.new()
	dive_timer.set_wait_time(0.5)
	dive_timer.one_shot = true
	dive_timer.connect("timeout", self, "_on_dive_timeout")
	add_child(dive_timer)
	dive_timer.start()

	fall_sound = AudioStreamPlayer3D.new()
	fall_sound.set_stream(load("res://assets/sound/snail_whistle.ogg"))
#	add_child(fall_sound)
#	fall_sound.play()

func unhandled_input(event: InputEvent) -> int:
	if event.is_action_pressed(Device.action_main):

		if entity.is_submerged() or is_on_surface() or entity.can_late_jump:
			return State.JUMP
		else:
			entity.jump_in_memory = true
			stored_jump_timer.start()

	if event.is_action_pressed(Device.trigger_right):
			return State.GPND

	if event.is_action_pressed(Device.action_alt):
		return State.SPIN

	return State.NULL

func physics_process(delta: float) -> int:
	set_movement(delta, 1.3 + (entity.move_momentum * 0.5), 0.5)

	if entity.fall_momentum <= 10:
		if entity.boosting:
			entity.fall_momentum += 8.5 * delta
		else:
			entity.fall_momentum += 10.0 * delta

	if is_on_surface():
		if entity.move_direction.length() > 0.01:
			return State.MOVE
		else:
			return State.IDLE

	return State.NULL

func _late_jump_timeout() -> void:
	entity.can_late_jump = false

func _stored_jump_timeout() -> void:
	entity.jump_in_memory = false

func _on_dive_timeout() -> void:
	can_dive = true

func exit() -> void:
	can_dive = false
	entity.can_turn = true
	entity.can_late_jump = false

	entity.move_momentum = entity.move_momentum * 0.333
	entity.fall_momentum = 0.0
	entity.jump_strength = 0

	fall_sound.stop()
	fall_sound.queue_free()

	late_jump_timer.queue_free()
	stored_jump_timer.queue_free()
	dive_timer.queue_free()

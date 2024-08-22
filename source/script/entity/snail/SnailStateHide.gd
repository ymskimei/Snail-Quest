extends SnailState

var roll_sound: AudioStreamPlayer3D
var slide_timer: Timer
var spin_timer: Timer

var input_spin: int = 0

func enter() -> void:
	print_state_name(STATE_NAMES, State.HIDE)

	entity.anim_states.travel("SnailHidden")

	#roll_sound = AudioStreamPlayer3D.new()
	#roll_sound.set_stream(load("res://assets/sound/snail_roll.ogg"))
	#add_child(roll_sound)
	#roll_sound.play()

	spin_timer = Timer.new()
	spin_timer.set_one_shot(true)
	spin_timer.set_wait_time(0.5)
	spin_timer.connect("timeout", self, "_on_spin_timer")
	spin_timer.set_name("SpinTimer")
	add_child(spin_timer)

func unhandled_input(event: InputEvent) -> int:
	if is_on_surface():
		if event.is_action_pressed(Device.action_main):
			return State.JUMP

		if event.is_action_released(Device.trigger_right):
			return State.IDLE

	return State.NULL

func physics_process(delta: float) -> int:

	if Input.is_action_just_pressed(Device.stick_main_left) or Input.is_action_just_pressed(Device.stick_main_right) or Input.is_action_just_pressed(Device.stick_main_up) or Input.is_action_just_pressed(Device.stick_main_down):
		entity.play_sound_peel(false)

		if Input.is_action_just_pressed(Device.stick_main_left) or Input.is_action_just_pressed(Device.stick_main_right):
			entity.anim_states.travel("SnailPeelingHorizontal")
		elif Input.is_action_just_pressed(Device.stick_main_up) or Input.is_action_just_pressed(Device.stick_main_down):
			entity.anim_states.travel("SnailPeelingVertical")
		input_spin += 1
		spin_timer.start()

		if input_spin >= 5:
			entity.play_sound_peel(true)
			return State.ROLL

	if entity.boost_direction.length() > 0.01:
		return State.JUMP

	if !is_on_surface():
		entity.can_late_jump = true
		return State.FALL
	return State.NULL

func _on_spin_timer() -> void:
	entity.anim_states.travel("SnailHidden")
	input_spin = 0

func exit() -> void:
	input_spin = 0

	#roll_sound.stop()
	#roll_sound.queue_free()

	spin_timer.queue_free()

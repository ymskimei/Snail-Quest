extends SnailStateMain

var roll_sound: AudioStreamPlayer3D 
var boost_timer: Timer
var slide_timer: Timer

func enter() -> void:
	print("Snail State: ROLL")
	roll_sound = AudioStreamPlayer3D.new()
	roll_sound.set_stream(load("res://assets/sound/snail_roll.ogg"))
	add_child(roll_sound)
	roll_sound.play()

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

	set_movement(delta, 1.4 + entity.move_momentum, true, false, 0.9, 1)
	entity.anim_tree.set("parameters/SnailRoll/TimeScale/scale", entity.direction.length() * 1.75)

	var roll_speed = abs(entity.direction.length())
	if roll_speed != 0:
		roll_sound.set_unit_db(roll_speed)
		roll_sound.set_pitch_scale(roll_speed * 2)


	if !is_on_surface(true):
		entity.can_late_jump = true
		return State.FALL
	return State.NULL

func _on_boost_timeout() -> void:
	entity.boosting = true

func exit() -> void:
	roll_sound.stop()
	roll_sound.queue_free()
	entity.anim.set_speed_scale(1.0)
	boost_timer.stop()

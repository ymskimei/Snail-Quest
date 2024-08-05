extends SnailState

var wait_timer: Timer = Timer.new()

func enter() -> void:
	print_state_name(STATE_NAMES, State.HIDE)

	entity.anim_states.travel("SnailHide")

	entity.zero_gravity = true
	entity.zero_movement = true

	entity.fall_momentum = 0
	entity.jump_strength = 0

	wait_timer = Timer.new()
	wait_timer.set_wait_time(0.25)
	wait_timer.one_shot = true
	wait_timer.connect("timeout", self, "_on_wait_timeout")
	add_child(wait_timer)
	wait_timer.start()

func physics_process(delta: float) -> int:
	set_movement(delta, 0.25)

	if !entity.zero_gravity:
		if entity.fall_momentum <= 10:
			entity.fall_momentum += 6 * delta

		entity.boost_direction = Vector3.DOWN * 7.5 + Vector3.DOWN * entity.fall_momentum

	if is_on_surface():
		if entity.move_direction.length() > 0.01:
			return State.ROLL
		else:
			return State.HIDE

	return State.NULL

func _on_wait_timeout() -> void:
	entity.zero_gravity = false
	entity.zero_movement = false

func exit() -> void:
	entity.fall_momentum = 0

	Utility.damage(entity, Vector3(2.0, 0.5, 2.0), 0.5, 0.2)

	entity.play_sound_slam()
	wait_timer.queue_free()


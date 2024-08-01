extends SnailState

var can_spin: bool = true
var wait_timer: Timer = Timer.new()

func enter() -> void:
	print("SPEE")
	entity.anim_states.start("SnailSpin")
	Utility.damage(entity, Vector3(1.0, 0.5, 1.0), 1.0)
	can_spin = true
	entity.fall_momentum = 0
	wait_timer = Timer.new()
	wait_timer.set_wait_time(0.25)
	wait_timer.one_shot = true
	wait_timer.connect("timeout", self, "_on_wait_timeout")
	add_child(wait_timer)
	wait_timer.start()
	entity.play_sound_swipe()

func physics_process(delta: float) -> int:
	set_rotation(delta)
	# Checks if entity is on the ground
	if !can_spin:
		if !is_on_surface(true):
			return State.FALL
		elif entity.direction != Vector3.ZERO:
			return State.MOVE
		else:
			return State.IDLE

	if entity.boosting and entity.direction.length() >= 1.8:
		if entity.move_momentum < entity.max_momentum:
			entity.move_momentum += 0.35 * delta

	if entity.is_submerged():
		set_movement(delta, 0.6 + entity.move_momentum, true, false, 1.0, 5.0)
	else:
		set_movement(delta, 0.5 + entity.move_momentum)

	return State.NULL

func _on_wait_timeout() -> void:
	can_spin = false

func exit() -> void:
	can_spin = false
	wait_timer.queue_free()


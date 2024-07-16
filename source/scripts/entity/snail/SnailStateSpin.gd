extends SnailState

var can_spin: bool = true
var wait_timer: Timer = Timer.new()

func enter() -> void:
	print("SPEE")
	entity.anim_states.travel("SnailSpin")
	can_spin = true
	entity.fall_momentum = 0
	wait_timer = Timer.new()
	wait_timer.set_wait_time(0.5)
	wait_timer.one_shot = true
	wait_timer.connect("timeout", self, "_on_wait_timeout")
	add_child(wait_timer)
	wait_timer.start()
	entity.play_sound_swipe(2)

func physics_process(delta: float) -> int:
	set_gravity(delta)

	# Checks if entity is on the ground
	if !can_spin:
		if !is_on_surface(true):
			return State.FALL
		elif entity.direction != Vector3.ZERO:
			return State.MOVE
		else:
			return State.IDLE

	return State.NULL

func _on_wait_timeout() -> void:
	can_spin = false

func exit() -> void:
	can_spin = false
	wait_timer.queue_free()


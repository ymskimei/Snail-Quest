extends SnailState

var can_pound: bool = false
var wait_timer: Timer = Timer.new()

func enter() -> void:
	print("gno")
	entity.anim_states.travel("SnailHide")
	#entity.play_sound_swipe(0)
	can_pound = false
	entity.fall_momentum = 0
	wait_timer = Timer.new()
	wait_timer.set_wait_time(0.25)
	wait_timer.one_shot = true
	wait_timer.connect("timeout", self, "_on_wait_timeout")
	add_child(wait_timer)
	wait_timer.start()

func physics_process(delta: float) -> int:
	if can_pound:
		if entity.fall_momentum <= 10:
			entity.fall_momentum += 6 * delta

	entity.move_and_collide((Vector3.DOWN * entity.fall_momentum), false)

	# Checks if entity is on the ground
	if is_on_surface(true):
		if entity.direction != Vector3.ZERO:
			return State.ROLL
		else:
			return State.HIDE

	return State.NULL

func _on_wait_timeout() -> void:
	can_pound = true

func exit() -> void:
	entity.play_sound_slam()
	can_pound = false

	entity.fall_momentum = 0

	wait_timer.queue_free()


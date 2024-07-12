extends SnailStateMain

var can_pound: bool = false
var wait_timer: Timer = Timer.new()

func enter() -> void:
	print("gno")
	can_pound = false
	entity.fall_momentum = 0
	wait_timer = Timer.new()
	wait_timer.set_wait_time(0.9)
	wait_timer.one_shot = true
	wait_timer.connect("timeout", self, "_on_wait_timeout")
	add_child(wait_timer)
	wait_timer.start()

func physics_process(delta: float) -> int:
	if can_pound:
		set_gravity(delta)
		if entity.fall_momentum <= 10:
			entity.fall_momentum += 6 * delta

	entity.move_and_collide(Vector3.DOWN * entity.fall_momentum)

	# Checks if entity is on the ground
	if is_on_surface(true):
		if entity.direction != Vector3.ZERO:
			return State.MOVE
		else:
			return State.IDLE

	return State.NULL

func _on_wait_timeout() -> void:
	can_pound = true

func exit() -> void:
	can_pound = false

	entity.fall_momentum = 0

	wait_timer.queue_free()


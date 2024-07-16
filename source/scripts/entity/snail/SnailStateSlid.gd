extends SnailState

var sliding_timer: Timer = Timer.new()
var sliding_end: bool = false

func enter() -> void:
	print("KYA")
	sliding_timer = Timer.new()
	sliding_timer.set_wait_time(0.6)
	sliding_timer.one_shot = true
	sliding_timer.connect("timeout", self, "_on_sliding_timeout")
	add_child(sliding_timer)
	sliding_timer.start()

func physics_process(delta: float) -> int:
	set_gravity(delta)
	set_movement(delta, 1.0, false, true)

	entity.move_momentum -= 5 * delta

	if sliding_end:
		return State.MOVE

	if !is_on_surface(true):
		return State.FALL
	return State.NULL

func _on_sliding_timeout() -> void:
	sliding_end = true

func exit() -> void:
	sliding_end = false



extends SnailStateMain

var jumping: bool = true
var jump_timer: Timer = Timer.new()

func enter() -> void:
	print("Snail State: JUMP")
	entity.anim.play("SnailJump")
	entity.jump_in_memory = false
	entity.fall_momentum = 1

	jumping = true

	jump_timer = Timer.new()
	jump_timer.set_wait_time(0.1)
	jump_timer.one_shot = true
	jump_timer.connect("timeout", self, "_on_jump_timeout")
	add_child(jump_timer)
	jump_timer.start()

func unhandled_input(event: InputEvent) -> int:
	if event.is_action_released(Device.action_main):
		jumping = false
	if event.is_action_pressed(Device.trigger_right):
			return State.GPND

	return State.NULL

func physics_process(delta: float) -> int:

	set_movement(delta, 1.15 + (entity.move_momentum * 0.5), true, false, 0.825)
	set_rotation(delta * 0.5)

	entity.move_and_collide((Vector3.UP * 0.2) * entity.fall_momentum)

	if !jumping:
		entity.fall_momentum -= 7 * delta
	if entity.fall_momentum <= 0:

		return State.FALL
	return State.NULL

func _on_jump_timeout() -> void:
	jumping = false

func exit() -> void:
	jump_timer.queue_free()


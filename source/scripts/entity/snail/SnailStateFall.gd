extends SnailStateMain

var can_dive: bool = false

var late_jump_timer: Timer = Timer.new()
var stored_jump_timer: Timer = Timer.new()
var dive_timer: Timer = Timer.new()

func enter() -> void:
	print("Snail State: FALL")
	entity.anim.play("SnailFall")
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

func unhandled_input(event: InputEvent) -> int:
	if event.is_action_pressed(Device.action_main):
		if is_on_surface(true) or entity.can_late_jump:
			return State.JUMP
		else:
			entity.jump_in_memory = true
			stored_jump_timer.start()
	if event.is_action_pressed(Device.trigger_right):
			return State.GPND

	return State.NULL

func physics_process(delta: float) -> int:
	set_rotation(delta)
	if entity.can_turn:
		set_movement(delta, 1.25 + (entity.move_momentum * 0.5))

	entity.move_and_collide(Vector3.DOWN * 0.7 * entity.fall_momentum)

	if entity.fall_momentum <= 10:
		if entity.boosting:
			entity.fall_momentum += 1.6 * delta
		else:
			entity.fall_momentum += 3 * delta

	# Checks if entity is on the ground
	if is_on_surface(true):
		if entity.direction != Vector3.ZERO:
#			if entity.move_momentum >= entity.max_momentum:
#				entity.temporary_exhaustion = true
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
	entity.fall_momentum = 0.0
	entity.move_momentum = entity.move_momentum * 0.333
	entity.can_turn = true
	entity.can_late_jump = false
	dive_timer.queue_free()


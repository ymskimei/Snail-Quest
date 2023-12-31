extends SnailStateMain

var ledge_jump_timer: Timer
var speed_boost_timer: Timer

export var can_ledge_jump: bool = false

func enter() -> void:
	print("Snail State: MOVE")
	entity.anim.play("SnailMove")
	entity.linear_damp = 50
	ledge_jump_timer = Timer.new()
	ledge_jump_timer.set_wait_time(2)
	ledge_jump_timer.one_shot = true
	ledge_jump_timer.connect("timeout", self, "on_ledge_jump_timeout")
	add_child(ledge_jump_timer)
	ledge_jump_timer.start()

func unhandled_input(event: InputEvent) -> int:
	if !entity.can_interact and event.is_action_pressed("action_main") and is_on_floor():
		return State.JUMP
	#if event.is_action_pressed("action_defense") or roll(event):
	#	return State.DODG
	needle()
	mallet()
	return State.NULL

func physics_process(delta: float) -> int:
	.physics_process(delta)
	var anim_speed = clamp((abs(entity.linear_velocity.x) + abs(entity.linear_velocity.y) + abs(entity.linear_velocity.z)), 0, 2) * 0.75
	entity.anim.set_speed_scale(anim_speed)
	if entity.ray_front_bottom.is_colliding():
		if entity.ray_front_top.is_colliding() and !entity.ray_bottom.is_colliding():
			return State.FALL
	if entity.jump_in_memory and !entity.can_interact:
		return State.JUMP
	if !direction:
		return State.IDLE
	return State.NULL

func integrate_forces(state: PhysicsDirectBodyState) -> int:
	.integrate_forces(state)
	apply_movement(state, 8)
	if !is_on_floor() and !entity.jump_in_memory and can_ledge_jump:
		entity.apply_central_impulse(3 * entity.global_transform.basis.y)
		return State.FALL
	return State.NULL

func on_ledge_jump_timeout():
	can_ledge_jump = true

func exit() -> void:
	entity.anim.set_speed_scale(1)
	ledge_jump_timer.queue_free()
	entity.linear_damp = -1

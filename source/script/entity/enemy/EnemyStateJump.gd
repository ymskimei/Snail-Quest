extends EnemyStateMain

var timer: Timer = Timer.new()

func enter() -> void:
	print("Enemy State: JUMP")
	entity.anim.play("PawnJump")
	snap_vector = Vector3.ZERO
	state_done = false
	timer.one_shot = true
	timer.connect("timeout", self, "end_wait")
	add_child(timer)
	timer.set_wait_time(0.3)
	timer.start()

func physics_process(delta: float) -> int:
	.physics_process(delta)
	apply_gravity(delta)
	apply_movement(delta, 5)
	entity.velocity.y += (entity.jump * 50) * delta
	entity.navi_agent.set_target_location(entity.target.transform.origin)
	if state_done:
		return State.FALL
	return State.NULL

func end_wait() -> void:
	state_done = true

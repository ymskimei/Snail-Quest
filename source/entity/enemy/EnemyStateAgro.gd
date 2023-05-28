extends EnemyStateMain

var timer = Timer.new()

func enter():
	print("Enemy State: AGRO")
	entity.anim.play("PawnIdle")
	snap_vector = Vector3.DOWN
	entity.velocity = Vector3.ZERO
	state_done = false
	timer.one_shot = true
	timer.connect("timeout", self, "end_wait")
	add_child(timer)
	timer.set_wait_time(randi() % 5 + 1)
	timer.start()

func physics_process(delta: float) -> int:
	.physics_process(delta)
	apply_gravity(delta)
	chase_locked()
	MathHelper.slerp_look_at(entity, Vector3(target_loc.x, entity.transform.origin.y, target_loc.z), 0.1)
	if can_chase:
		return State.TARG
	if !entity.target_seen:
		return State.IDLE
	if state_done:
		return State.JUMP
	return State.NULL

func end_wait():
	if randi() % 3:
		state_done = true  
	rotate()
	timer.set_wait_time(randi() % 5 + 1)
	timer.start()

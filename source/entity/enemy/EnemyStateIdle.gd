extends EnemyStateMain

var timer = Timer.new()

func enter():
	print("Enemy State: IDLE")
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
	entity.rotation.y = lerp(entity.rotation.y, look_dir, 0.05)
	if state_done:
		return State.MOVE
	if entity.target_seen:
		return State.TARG
	return State.NULL

func end_wait():
	if randi() % 2:
		state_done = true  
	rotate()
	timer.set_wait_time(randi() % 5 + 1)
	timer.start()

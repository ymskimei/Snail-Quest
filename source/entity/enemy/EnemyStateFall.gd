extends EnemyStateMain

var timer = Timer.new()

func enter():
	print("Enemy State: FALL")
	entity.anim.play("PawnIdle")
	state_done = false
	timer.one_shot = true
	timer.connect("timeout", self, "end_wait")
	add_child(timer)
	timer.set_wait_time(0.5)
	timer.start()

func physics_process(delta: float) -> int:
	.physics_process(delta)
	if !state_done:
		entity.velocity = Vector3.ZERO
	else:
		entity.anim.play("PawnFall")
		snap_vector = Vector3.DOWN
		apply_gravity(delta)
		if entity.is_on_floor():
			entity.attack_area.monitorable = false
			if entity.target_seen:
				return State.AGRO
			else:
				return State.IDLE
	return State.NULL

func end_wait():
	entity.attack_area.monitorable = true
	state_done = true

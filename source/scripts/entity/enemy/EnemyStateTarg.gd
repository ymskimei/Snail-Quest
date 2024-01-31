extends EnemyStateMain

func enter() -> void:
	print("Enemy State: TARG")
	entity.anim.play("PawnMove")
	snap_vector = Vector3.DOWN
	entity.velocity = Vector3.ZERO
	
func physics_process(delta: float) -> int:
	super.physics_process(delta)
	apply_gravity(delta)
	chase_locked()
	MathHelper.slerp_look_at(entity, Vector3(target_loc.x, entity.transform.origin.y, target_loc.z), 0.1)
	entity.navi_agent.set_target_position(entity.target.transform.origin)
	apply_movement(delta, 1)
	if !can_chase:
		if randi() % 2:
			return State.JUMP
		else:
			return State.AGRO
	if !entity.target_seen:
		return State.IDLE
	return State.NULL

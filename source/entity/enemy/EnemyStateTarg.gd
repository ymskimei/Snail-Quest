extends EnemyStateMain

func enter():
	print("Enemy State: TARG")
	entity.anim.play("PawnMove")

func physics_process(delta: float) -> int:
	.physics_process(delta)
	apply_gravity(delta)
	MathHelper.slerp_look_at(entity, Vector3(target_loc.x, entity.transform.origin.y, target_loc.z), 0.1)
	entity.navi_agent.set_target_location(entity.target.transform.origin)
	move(delta, 0.5)
	if !can_chase:
		return State.AGRO
	if !entity.target_seen:
		return State.IDLE
	return State.NULL

extends EnemyStateMain

func enter() -> void:
	print("Enemy State: SEEK")

func physics_process(delta: float) -> int:
	.physics_process(delta)
	rot_speed = 0.08
	var global_pos = entity.global_transform.origin
	var target_pos = entity.target.global_transform.origin
	var w_transform = entity.global_transform.looking_at(Vector3(target_pos.x, global_pos.y, target_pos.z), Vector3.UP)
	var w_rotation = Quat(entity.global_transform.basis).slerp(Quat(w_transform.basis), rot_speed)
	entity.global_transform = Transform(Basis(w_rotation), global_pos)
	entity.navi_agent.set_target_location(entity.target_location.transform.origin)
	var next = entity.navi_agent.get_next_location()
	var velocity = (next - entity.transform.origin).normalized() * entity.speed * delta
	entity.move_and_collide(velocity)
	if !entity.target_near:
		return State.LOOK
	return State.NULL

extends EnemyStateMain

func enter() -> void:
	print("Enemy State: SEEK")

func physics_process(delta: float) -> int:
	rot_speed = 0.08
	var global_pos = enemy.global_transform.origin
	var target_pos = enemy.target.global_transform.origin
	var w_transform = enemy.global_transform.looking_at(Vector3(target_pos.x, global_pos.y, target_pos.z), Vector3.UP)
	var w_rotation = Quat(enemy.global_transform.basis).slerp(Quat(w_transform.basis), rot_speed)
	enemy.global_transform = Transform(Basis(w_rotation), global_pos)
	enemy.navi_agent.set_target_location(enemy.target_location.transform.origin)
	var next = enemy.navi_agent.get_next_location()
	var velocity = (next - enemy.transform.origin).normalized() * enemy.speed * delta
	enemy.move_and_collide(velocity)
	if !enemy.target_near:
		return State.LOOK
	return State.NULL

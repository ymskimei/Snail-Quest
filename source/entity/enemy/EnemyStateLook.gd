extends EnemyStateMain

func enter() -> void:
	print("Enemy State: LOOK")

func physics_process(delta: float) -> int:
	var global_pos = enemy.global_transform.origin
	var target_pos = enemy.target.global_transform.origin
	var wtransform = enemy.global_transform.looking_at(Vector3(target_pos.x, global_pos.y, target_pos.z), Vector3.UP)
	var wrotation = Quat(enemy.global_transform.basis).slerp(Quat(wtransform.basis), rot_speed)
	self.global_transform = Transform(Basis(wrotation), global_pos)
	if !enemy.is_on_floor():
		enemy.move_and_collide(-enemy.global_transform.basis.y.normalized() * enemy.gravity * delta)
	if enemy.escaped_yet:
		return State.MOVE
	return State.NULL

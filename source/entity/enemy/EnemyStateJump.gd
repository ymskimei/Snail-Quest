extends EnemyStateMain

var look_dir
var timer = Timer.new()

func enter():
	print("Enemy State: JUMP")
	entity.anim.play("PawnIdle")
	timer.one_shot = true
	timer.connect("timeout", self, "end_wait")
	add_child(timer)
	timer.wait_time = randi() % 2 + 1
	timer.start()

func physics_process(delta: float) -> int:
	.physics_process(delta)
	apply_gravity(delta)
	if entity.target_seen:
		return State.BATT
	return State.NULL

func end_wait():
	rotate()
	timer.wait_time = randi() % 2 + 1
	timer.start()

func rotate():
	look_dir = entity.rotation.y + deg2rad((randi() % 270) - 135)
	entity.rotation.y == look_dir

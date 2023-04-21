extends EnemyStateMain

var look_dir
var timer = Timer.new()
var state_done : bool

func enter():
	print("Enemy State: IDLE")
	entity.anim.play("PawnIdle")
	look_dir = entity.rotation.y
	state_done = false
	timer.one_shot = true
	timer.connect("timeout", self, "end_wait")
	add_child(timer)
	timer.wait_time = randi() % 5 + 1
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
	timer.wait_time = randi() % 5 + 1
	timer.start()

func rotate():
	print("test")
	look_dir = entity.rotation.y + deg2rad((randi() % 270) - 135)
	

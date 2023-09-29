extends EnemyStateMain

var timer: Timer = Timer.new()

func enter() -> void:
	print("Enemy State: MOVE")
	entity.anim.play("PawnMove")
	snap_vector = Vector3.DOWN
	state_done = false
	timer.one_shot = true
	timer.connect("timeout", self, "end_wait")
	timer.set_wait_time(randi() % 5 + 1)
	timer.start()

func physics_process(delta: float) -> int:
	.physics_process(delta)
	apply_gravity(delta)
	entity.rotation.y = lerp(entity.rotation.y, look_dir, 0.05)
	var current_loc = entity.transform.origin
	var rot = entity.rotation.y + deg2rad((randi() % 80) - 40) + PI 
	var dist = randi() % 7 + 1
	var new_loc_x = (dist * sin(rot))
	var new_loc_z = (dist * cos(rot)) 
	entity.navi_agent.set_target_location(entity.transform.origin + Vector3(new_loc_x, 0, new_loc_z))
	apply_movement(delta, 1)
	if state_done:
		return State.IDLE
	if entity.target_seen:
		return State.AGRO
	return State.NULL

func end_wait() -> void:
	if randi() % 2:
		state_done = true  
	rotate()
	timer.set_wait_time(randi() % 5 + 1)
	timer.start()

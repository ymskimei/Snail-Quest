extends EnemyStateMain

var mid_state = MidState.DECIDE

var timer = Timer.new()
var timer_set = false
var move_set = false
var look_dir

enum MidState {
	LOOK, MOVE, WAIT, DECIDE
}

func _ready():
	timer.one_shot = true
	timer.connect("timeout", self, "end_wait")
	add_child(timer)

func enter():
	print("setting thing")
	mid_state = MidState.DECIDE

func physics_process(delta: float) -> int:
	.physics_process(delta)
	match (mid_state):
		MidState.DECIDE:
			mid_state = randi() % 4
		MidState.LOOK:
			if look_dir == null:
				look_dir = entity.rotation.y + deg2rad((randi() % 270) - 135)
				start_wait()
			else:
				rotate(delta)
		MidState.MOVE:
			if !move_set:
				var current_loc = entity.transform.origin
				var rot = entity.rotation.y + deg2rad((randi() % 80) - 40) + PI 
				var dist = randi() % 7 + 1
				var new_loc_x = (dist * sin(rot))
				var new_loc_z = (dist * cos(rot)) 
				look_dir = rot + PI
				entity.navi_agent.set_target_location(entity.transform.origin + Vector3(new_loc_x,0,new_loc_z))
				move_set = true
				start_wait()
				entity.navi_agent.connect("target_reached", self, "reset_move")
			else:
				rotate(delta)
				move(delta)
		MidState.WAIT:
			if !timer_set:
				start_wait()
	return State.NULL

func start_wait():
	timer_set = true
	timer.wait_time = randi() % 2 + 1
	timer.start()

func end_wait():
	timer_set = false
	look_dir = null
	mid_state = MidState.DECIDE
	reset_move()

func reset_move():
	move_set = false
	mid_state = MidState.DECIDE

func move(delta):
	var current = entity.transform.origin
	var next = entity.navi_agent.get_next_location()
	var velocity = (next - current).normalized() * delta * entity.speed
	#entity.move_and_collide(velocity)

func rotate(delta):
	if (entity.rotation.y == look_dir):
		look_dir = null
		mid_state = MidState.DECIDE
	else:
		entity.rotation.y = lerp_angle(entity.rotation.y, look_dir, delta * 5)


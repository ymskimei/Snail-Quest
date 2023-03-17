class_name EnemyParent
extends EntityParent

var idle_speed = rand_range(speed / 2, speed * 3)
var move_or_not = [true, false]
var start_move = move_or_not[randi() % move_or_not.size()]

onready var target = $"../../Player"

onready var navi_agent : NavigationAgent = $NavigationAgent
onready var target_location : Node = $"../../Player"

onready var looking_timer = $LookingTimer
onready var follow_timer = $FollowTimer
onready var states = $States

var target_near : bool
var escaped_yet : bool

func _ready():
	states.ready(self)

func _physics_process(delta):
	print(states)
	if states != null:
		states.physics_process(delta)

func _on_Area_body_entered(body):
	if body.name == ("Player"):
		target_near = true

func _on_Area_body_exited(body):
	if body.name == ("Player"):
		target_near = false
		escaped_yet = false
		follow_timer.start()

func _on_NavigationAgent_velocity_computed(safe_velocity):
	move_and_collide(safe_velocity)

func _on_LookingTimer_timeout():
	looking_timer.set_wait_time(rand_range(4, 8))
	idle_speed = rand_range(speed / 2, speed * 3)
	start_move = move_or_not[randi() % move_or_not.size()]
	looking_timer.start()

func _on_FollowTimer_timeout():
	print("escaped")
	escaped_yet = true

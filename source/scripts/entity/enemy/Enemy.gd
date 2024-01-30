class_name Enemy
extends Entity

var idle_speed: int = int(rand_range(speed / 2, speed * 3))
var move_or_not = [true, false]
var start_move = move_or_not[randi() % move_or_not.size()]

onready var attack_area: Area = $"%AttackArea"

onready var navi_agent: NavigationAgent = $NavigationAgent

onready var follow_timer: Timer = $FollowTimer

var target_seen: bool
var is_pushed: bool

func _ready() -> void:
	attack_area.monitorable = false
	states.ready(self)
	target = SB.player
#func _physics_process(delta):
#	if states != null:
#		states.physics_process(delta)

func _on_Area_area_entered(area: Area) -> void:
	if area.is_in_group("attack"):
		var damage = area.get_parent().get_parent().strength
		#if damage >= 0.15 * max_health:
			#strike_flash(area)
		set_entity_health(-damage)
#		if !follow_timer.is_stopped():
#			follow_timer.start()

func _on_Area_body_entered(body) -> void:
	if body.name == ("Player"):
		target_seen = true
		follow_timer.paused = true

func _on_Area_body_exited(body) -> void:
	if body.name == ("Player"):
		follow_timer.paused = false
		follow_timer.start()

func _on_NavigationAgent_velocity_computed(safe_velocity) -> void:
	#move_and_collide(safe_velocity)
	pass

func _on_FollowTimer_timeout() -> void:
	print("escaped")
	target_seen = false

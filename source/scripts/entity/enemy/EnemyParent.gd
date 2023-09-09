class_name EnemyParent
extends EntityParent

var idle_speed: int = int(rand_range(speed / 2, speed * 3))
var move_or_not = [true, false]
var start_move = move_or_not[randi() % move_or_not.size()]

onready var target: Spatial = GlobalManager.player
onready var attack_area: Area = $"%AttackArea"

onready var navi_agent: NavigationAgent = $NavigationAgent

onready var follow_timer: Timer = $FollowTimer
onready var states: Node = $StateController
onready var anim: AnimationPlayer = $AnimationPlayer

signal health_changed

var target_seen: bool
var is_pushed: bool

func _ready() -> void:
	attack_area.monitorable = false
	states.ready(self)

#func _physics_process(delta):
#	if states != null:
#		states.physics_process(delta)

func inflict_damage(damage_amount: int) -> void:
	set_current_health(health - damage_amount)
	print("Enemy Health: " + str(health))

func set_current_health(new_amount: int) -> void:
	health = new_amount
	emit_signal("health_changed", new_amount)
	debug_healthbar()
	if health <= 0:
		queue_free()

func _on_Area_area_entered(area: Area) -> void:
	if area.is_in_group("attack"):
		var damage = area.get_parent().get_parent().strength
		if damage >= 0.15 * max_health:
			strike_flash(area)
		inflict_damage(damage)
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

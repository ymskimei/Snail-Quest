extends VehicleBody

onready var mesh = $MeshInstance
onready var engine = $AudioStreamPlayer3D
onready var anim = $Tween

var mounted: bool = false
var max_speed: int = 500
var speed_multiplier: float = 1.5

var boost_remaining: int = 10
var boost_max: int = 10
var boosting: bool = false
var can_boost: bool = true

var character: bool

var boost_timer: Timer = Timer.new()
var boost_replenish: Timer = Timer.new()

signal boosted

func _ready():
	boost_timer.connect("timeout", self, "on_boost_timeout")
	boost_replenish.connect("timeout", self, "on_replenish_timeout")
	boost_timer.set_wait_time(1)
	boost_replenish.set_wait_time(5)
	boost_replenish.one_shot = true
	add_child(boost_timer)
	add_child(boost_replenish)
	if engine.pitch_scale != 0:
		engine.set_pitch_scale(0)
	engine.play()

func _unhandled_input(event):
	if event.is_action_pressed("action_main"):
		if can_boost and boost_remaining > 0:
			boosting = true
			speed_multiplier = 1.7
			emit_signal("boosted", boosting)
			boost_timer.start()
	elif event.is_action_released("action_main"):
		boosting = false
		speed_multiplier = 1.0
		emit_signal("boosted", boosting)
		boost_timer.stop()
	if event.is_action_pressed("action_defense") and mounted:
		unmount()

func _physics_process(delta):
	if mounted:
		steering = lerp(steering, Input.get_axis("joy_right", "joy_left") * 0.5, 3 * delta)
		engine_force = lerp(engine_force, Input.get_axis("joy_up", "joy_down") * max_speed * speed_multiplier, delta)
		var engine_pitch = abs(engine_force) / (max_speed / 2)
		if engine_pitch != 0:
			engine.pitch_scale = engine_pitch

func on_boost_timeout():
	if boosting:
		if boost_remaining <= 0:
			can_boost = false
			boost_replenish.start()
		else:
			boost_remaining -= 1
	else:
		speed_multiplier = 1
		boost_remaining += 1
		if boost_remaining >= 10:
			can_boost = true

func on_replenish_timeout():
	boost_remaining = boost_max
	can_boost = true

func get_interaction_text():
	return "enter the vehicle"

func interact():
	mount()

func mount():
	var driver = SB.controlled
	SB.register_vehicle(self)
	SB.camera.update_target()
	driver.can_move = false
	mounted = true

func unmount():
	var driver = SB.controlled
	SB.deregister_vehicle()
	SB.camera.update_target()
	driver.can_move = false
	mounted = false
	engine_force = 0

func is_controlled() -> bool:
	if SB.controlled == self:
		return true
	return false

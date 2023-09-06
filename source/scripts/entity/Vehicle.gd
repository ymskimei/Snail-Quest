extends VehicleBody

onready var seat = $PinJoint
onready var engine = $AudioStreamPlayer3D
onready var anim = $Tween

var mounted : bool
var max_speed = 1300

func _ready():
	engine.pitch_scale = 0
	engine.play()

func _physics_process(delta):
	if mounted:
		steering = lerp(steering, Input.get_axis("joy_right", "joy_left") * 0.5, 3 * delta)
		engine_force = lerp(engine_force, Input.get_axis("joy_up", "joy_down") * max_speed, 2 * delta)
		if Input.is_action_just_pressed("action_defense"):
			unmount()
		var engine_pitch = abs(engine_force) / (max_speed / 2)
		if engine_pitch != 0:
			engine.pitch_scale = engine_pitch

func _on_Area_body_entered(body):
	if body is Player:
		#seat.nodes.node_a = body
		mount()

func mount():
	print("mounted")
	mounted = true
	GlobalManager.player.can_move = false

func unmount():
	print("unmounted")
	mounted = false
	GlobalManager.player.can_move = true
	engine_force = 0

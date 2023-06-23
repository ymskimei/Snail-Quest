class_name MainCamera
extends SpringArm

onready var player = get_parent().get_node("Player")
onready var camera_lens = $CameraLens
onready var anim_tween = $Animation/AnimationCam
onready var anim_bars = $Animation/AnimationBars
onready var anim_wobble = $Animation/AnimationWobble
onready var states = $StateController
var lock_target
var lock_to_point : bool

func _ready():
	states.ready(self)
	GlobalManager.register_camera(self)



func _physics_process(delta: float) -> void:
	states.physics_process(delta)
	find_camera_lock_points()

func update_player_target():
	for p in get_parent().get_children():
		if p is Player:
			if p.is_active_player:
				player = p

func _unhandled_input(event: InputEvent) -> void:
	states.unhandled_input(event)

func find_camera_lock_points():
	if is_instance_valid(lock_target):
		var target_distance = lock_target.get_global_translation().distance_to(player.get_global_translation())
		var max_lock_distance = 17
		if target_distance < max_lock_distance:
			lock_to_point = true
		else:
			lock_to_point = false
	else:
		lock_to_point = false
		lock_target = MathHelper.find_target(self, "camera")

func set_coords(position : Vector3, angle : String, flipped : bool):
	var rot = deg2rad(MathHelper.cardinal_to_degrees(angle))
	if flipped:
		if !rot == 0:
			rot /= 0.5
		else:
			rot = PI
	set_global_translation(position)
	set_global_rotation(Vector3(0, rot, 0))

extends RigidBody3D

@onready var attack_area = $"%AttackArea"
@onready var particles = $"%Particles"
@onready var anim = $AnimationPlayer

var stored_attacks = 0
var strength = 5

var throwing_velocity : Vector3
var throw_speed = 5
var gravity = 5

var is_throwing : bool

func _ready():
	attack_area.monitorable = false
	anim.connect("animation_finished", Callable(self, "on_animation_finished"))

func _physics_process(delta):
	if is_throwing:
		var velocity = throwing_velocity + (Vector3(0, -gravity, 0) * delta)
		position += velocity
		rotation = velocity.normalized().slerp(Vector3.FORWARD, velocity.length() / throw_speed)

func swing_left():
	attack_area.monitorable = true
	particles.emitting = true
	AudioPlayer.play_sfx(AudioPlayer.sfx_needle_swipe_1)
	anim.play("NeedleSwingHorizontal")
	await anim.animation_finished
	make_stationary()

func swing_right():
	attack_area.monitorable = true
	particles.emitting = true
	AudioPlayer.play_sfx(AudioPlayer.sfx_needle_swipe_0)
	anim.play_backwards("NeedleSwingHorizontal")
	await anim.animation_finished
	make_stationary()

func directional_swing():
	if Input.is_action_pressed("cam_left") or Input.is_action_pressed("cam_right") or Input.is_action_pressed("cam_up") or Input.is_action_pressed("cam_down"):
		particles.emitting = true
		rotation.y = clamp(lerp(rotation.y, (Input.get_action_raw_strength("cam_left") - Input.get_action_raw_strength("cam_right")) * 1.5, 0.4), deg_to_rad(-90), deg_to_rad(90))
		rotation.x = clamp(lerp(rotation.x, (Input.get_action_raw_strength("cam_down") - Input.get_action_raw_strength("cam_up")) * 1.5, 0.2), deg_to_rad(-45), deg_to_rad(90))
	else:
		make_stationary()

func throw(throw_direction : Vector3):
	throwing_velocity = throw_direction.normalized() * throw_speed
	is_throwing = true

func make_stationary():
	attack_area.monitorable = false
	particles.emitting = false
	rotation.y = 0
	rotation.x = 0

func _on_AnimationPlayer_animation_finished(anim_name):
	make_stationary()

extends RigidBody

onready var anim = $AnimationPlayer
var stored_attacks = 0
var strength = 5

func _ready():
	anim.connect("animation_finished", self, "on_animation_finished")

func swing_left():
	$"%Particles".emitting = true
	AudioPlayer.play_sfx(AudioPlayer.sfx_needle_swipe_1)
	anim.play("NeedleSwingHorizontal")
	yield(anim, "animation_finished")
	make_stationary()

func swing_right():
	$"%Particles".emitting = true
	AudioPlayer.play_sfx(AudioPlayer.sfx_needle_swipe_0)
	anim.play_backwards("NeedleSwingHorizontal")
	yield(anim, "animation_finished")
	make_stationary()

func directional_swing():
	if Input.is_action_pressed("cam_left") or Input.is_action_pressed("cam_right") or Input.is_action_pressed("cam_up") or Input.is_action_pressed("cam_down"):
		$"%Particles".emitting = true
		rotation.y = clamp(lerp(rotation.y, (Input.get_action_raw_strength("cam_left") - Input.get_action_raw_strength("cam_right")) * 1.5, 0.4), deg2rad(-90), deg2rad(90))
		rotation.x = clamp(lerp(rotation.x, (Input.get_action_raw_strength("cam_down") - Input.get_action_raw_strength("cam_up")) * 1.5, 0.2), deg2rad(-45), deg2rad(90))
	else:
		make_stationary()

func make_stationary():
	$"%Particles".emitting = false
	rotation.y = 0
	rotation.x = 0

func _on_AnimationPlayer_animation_finished(anim_name):
	make_stationary()

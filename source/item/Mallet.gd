extends RigidBody

onready var anim = $AnimationPlayer
var stored_attacks = 0

func _ready():
	anim.play("MalletStill")

func _unhandled_input(event):
	slam()

func slam():
	if Input.is_action_just_pressed("action_combat"):
		$"%Particles".emitting = true
		anim.play("MalletSlamDown")

func on_slam():
	AudioPlayer.play_sfx(AudioPlayer.sfx_mallet_slam)
	Input.start_joy_vibration(0, 1, 1, 0.2)
	$"%Area".monitorable = true

func _on_AnimationPlayer_animation_finished(anim_name):
	$"%Area".monitorable = false
	$"%Particles".emitting = false
	anim.play("MalletStill")

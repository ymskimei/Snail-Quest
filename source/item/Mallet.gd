extends RigidBody

onready var anim = $AnimationPlayer

export var damage_charge_0 = 4
export var damage_charge_1 = 6
export var damage_full_charge = 8

var current_damage = 0

func _ready():
	anim.play("MalletStill")

func slam():
	$"%Particles".emitting = true
	anim.play("MalletChargeSlam")

func on_charge_0():
	AudioPlayer.play_sfx(AudioPlayer.sfx_mallet_charge_0)
	current_damage = damage_charge_0

func on_charge_1():
	AudioPlayer.play_sfx(AudioPlayer.sfx_mallet_charge_1)
	current_damage = damage_charge_1

func on_full_charge():
	AudioPlayer.play_sfx(AudioPlayer.sfx_mallet_charge_2)
	current_damage = damage_full_charge
	end_slam()

func on_slam():
	if current_damage == damage_full_charge:
		AudioPlayer.play_sfx(AudioPlayer.sfx_mallet_full_slam)
		Input.start_joy_vibration(0, 1, 1, 0.25)
	else:
		AudioPlayer.play_sfx(AudioPlayer.sfx_mallet_slam)
		Input.start_joy_vibration(0, 1, 1, 0.2)
	$"%Area".monitorable = true
	current_damage = 0

func end_slam():
	if current_damage >= damage_full_charge:
		anim.play("MalletSlam")
	elif current_damage >= damage_charge_0:
		anim.play("MalletWeakSlam")
	else:
		cancel_slam()

func cancel_slam():
	$"%Area".monitorable = false
	$"%Particles".emitting = false
	current_damage = 0
	anim.play("MalletStill")

func _on_AnimationPlayer_animation_finished(anim_name):
	cancel_slam()

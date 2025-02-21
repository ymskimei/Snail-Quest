extends RigidBody

onready var attack_area = $"%AttackArea"
onready var particles = $"%Particles"
onready var anim = $AnimationPlayer

export var strength_charge_0 = 10
export var strength_charge_1 = 20
export var strength_full_charge = 40

var strength = 0

func _ready():
	attack_area.monitorable = false
	anim.play("MalletStill")

func slam():
	particles.emitting = true
	anim.play("MalletChargeSlam")

func swing_left():
	strength = strength_charge_0
	attack_area.monitorable = true
	particles.emitting = true
	anim.play("MalletSwingLeft")
	yield(anim, "animation_finished")
	attack_area.monitorable = false
	strength = 0

func swing_right():
	strength = strength_charge_0
	attack_area.monitorable = true
	particles.emitting = true
	anim.play("MalletSwingRight")
	yield(anim, "animation_finished")
	attack_area.monitorable = false
	strength = 0

func on_charge_0():
	AudioPlayer.play_sfx(AudioPlayer.sfx_mallet_charge_0)
	strength = strength_charge_0

func on_charge_1():
	AudioPlayer.play_sfx(AudioPlayer.sfx_mallet_charge_1)
	strength = strength_charge_1

func on_full_charge():
	AudioPlayer.play_sfx(AudioPlayer.sfx_mallet_charge_2)
	strength = strength_full_charge
	end_slam()

func on_slam():
	attack_area.monitorable = true
	if strength == strength_full_charge:
		AudioPlayer.play_sfx(AudioPlayer.sfx_mallet_full_slam)
		Device.start_joy_vibration(0, 1, 1, 0.25)
	else:
		AudioPlayer.play_sfx(AudioPlayer.sfx_mallet_slam)
		Device.start_joy_vibration(0, 1, 1, 0.2)

func end_slam():
	if strength >= strength_full_charge:
		anim.play("MalletSlam")
	elif strength >= strength_charge_0:
		anim.play("MalletWeakSlam")
	else:
		cancel_slam()

func cancel_slam():
	attack_area.monitorable = false
	particles.emitting = false
	strength = 0
	anim.play("MalletStill")

func _on_AnimationPlayer_animation_finished(anim_name):
	cancel_slam()

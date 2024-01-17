extends Interactable

onready var rod: RigidBody = $Lever/Handle
onready var grab_point: Position3D = $Lever/Handle/Position3D

var active: bool = false

signal activated(is_active)

func _input(event: InputEvent) -> void:
	if is_controlled():
		var rotation_timer_right: Timer = Timer.new()
		if Input.is_action_pressed(SB.utility.input.i_stick_main_down) and !active:
			_activate_switch()
		elif Input.is_action_pressed(SB.utility.input.i_stick_main_up) and active:
			_deactivate_switch()
		elif Input.is_action_pressed(SB.utility.input.i_action_main):
			SB.set_controlled(SB.prev_controlled)

func _activate_switch() -> void:
	anim.play_backwards("Switch")
	SB.utility.audio.play_pos_sfx(RegistryAudio.switch_on, global_translation)
	yield(anim, "animation_finished")
	active = true
	emit_signal("activated", active)

func _deactivate_switch() -> void:
	anim.play("Switch")
	SB.utility.audio.play_pos_sfx(RegistryAudio.switch_off, global_translation)
	yield(anim, "animation_finished")
	active = false
	emit_signal("activated", active)

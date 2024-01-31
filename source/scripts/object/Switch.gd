extends Interactable

@onready var rod: RigidBody3D = $Lever/Handle
@onready var grab_point: Marker3D = $Lever/Handle/Marker3D
@onready var anim: AnimationPlayer = $AnimationPlayer

var active: bool = false

signal activated(is_active)

func _input(event: InputEvent) -> void:
	if is_controlled():
		camera_override()
		var rotation_timer_right: Timer = Timer.new()
		if Input.is_action_pressed(Device.stick_main_down) and !active:
			_activate_switch()
		elif Input.is_action_pressed(Device.stick_main_up) and active:
			_deactivate_switch()
		elif Input.is_action_pressed(Device.action_main):
			if is_instance_valid(SB.prev_controlled):
				SB.prev_controlled.set_controlled()
	else:
		camera_override(false)

func _activate_switch() -> void:
	anim.play_backwards("Switch")
	Audio.play_pos_sfx(RegistryAudio.switch_on, global_position)
	await anim.animation_finished
	active = true
	emit_signal("activated", active)

func _deactivate_switch() -> void:
	anim.play("Switch")
	Audio.play_pos_sfx(RegistryAudio.switch_off, global_position)
	await anim.animation_finished
	active = false
	emit_signal("activated", active)

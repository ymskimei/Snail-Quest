extends ObjectParent

onready var rod: RigidBody = $Lever/Handle
onready var grab_point: Position3D = $Lever/Handle/Position3D
onready var camera_target_proxy: Spatial

export var current_camera_target: bool = false
export var active: bool = false

signal activated(is_active)

func _ready() -> void:
	camera_target_proxy = get_node_or_null("CameraTarget")

func _input(event: InputEvent) -> void:
	if is_controllable():
		current_camera_target = true
		var rotation_timer_right: Timer = Timer.new()
		if Input.is_action_pressed("joy_down") and !active:
			anim.play_backwards("Switch")
			AudioPlayer.play_pos_sfx(AudioPlayer.sfx_switch_on, global_translation)
			yield(anim, "animation_finished")
			active = true
			emit_signal("activated", active)
		elif Input.is_action_pressed("joy_up") and active:
			anim.play("Switch")
			AudioPlayer.play_pos_sfx(AudioPlayer.sfx_switch_off, global_translation)
			yield(anim, "animation_finished")
			active = false
			emit_signal("activated", active)
		elif Input.is_action_pressed("action_main"):
			GlobalManager.set_controllable(GlobalManager.prev_controllable)
	else:
		current_camera_target = false

func is_controllable() -> bool:
	if GlobalManager.controllable == self:
		return true
	return false

class_name AimCursor
extends MeshInstance

func _ready():
	global_translation = GlobalManager.player.global_translation

func _physics_process(delta):
	global_translation = lerp(global_translation, GlobalManager.player.global_translation + cursor_movement().rotated(Vector3.UP, GlobalManager.camera.rotation.y) * 3, 0.3)
	pass

func cursor_movement():
	var cursor_pos = Vector3.ZERO
	cursor_pos.x += clamp((Input.get_action_strength("joy_right") - Input.get_action_strength("joy_left")), -10, 10)
	cursor_pos.z += clamp((Input.get_action_strength("joy_down") - Input.get_action_strength("joy_up")), -10, 10)
	return cursor_pos

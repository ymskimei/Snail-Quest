class_name AimCursor
extends Spatial

func _ready():
	global_translation = GlobalManager.player.global_translation
	GlobalManager.register_aim_cursor(self)

func _physics_process(delta):
	$Mesh.rotation.y += 5 * delta
	global_translation = lerp(global_translation, GlobalManager.player.global_translation + cursor_movement().rotated(Vector3.UP, GlobalManager.camera.rotation.y) * 3, 0.3)
	level_cursor()
	pass

func cursor_movement():
	var cursor_pos = Vector3.ZERO
	cursor_pos.x += clamp((Input.get_action_strength("joy_right") - Input.get_action_strength("joy_left")), -10, 10)
	cursor_pos.z += clamp((Input.get_action_strength("joy_down") - Input.get_action_strength("joy_up")), -10, 10)
	return cursor_pos

func level_cursor():
	if $RayCast.is_colliding():
		var normal = $RayCast.get_collision_normal()
		var tform = MathHelper.apply_surface_align(global_transform, normal)
		global_transform = global_transform.interpolate_with(tform, 0.3)
		
		var floor_height = $RayCast.get_collider().translation.y
		print(floor_height)
		translation.y = floor_height + 1

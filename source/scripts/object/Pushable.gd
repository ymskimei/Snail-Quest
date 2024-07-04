class_name Pushable
extends Interactable

onready var anim_tween: Tween = $Tween

onready var rays_positive_x: Spatial = $Rays/RaysPX
onready var rays_negative_x: Spatial = $Rays/RaysNX
onready var rays_positive_z: Spatial = $Rays/RaysPZ
onready var rays_negative_z: Spatial = $Rays/RaysNZ

var dir: Vector2

var collider: PhysicsBody
var can_push: bool = true
var pushing: bool = false

func _physics_process(delta: float) -> void:
	if is_instance_valid(collider) and can_push:
		_push()

func interact():
	pass

func get_interaction_text() -> String:
	return "Push"

func _on_Pushable_body_entered(body):
	if body is Entity and body.is_controlled():
		collider = body
		can_push = true
		dir = _get_direction(body)
		print(dir)

func _on_Pushable_body_exited(body):
	if body is Entity and body.is_controlled():
		collider = null
		can_push = false

func is_pressed() -> bool:
	if collider:
		return true
	return false

func _get_direction(b: PhysicsBody):
	var x = b.linear_velocity.x
	var y = b.linear_velocity.z
	if abs(x) < abs(y):
		x = 0
	elif abs(x) > abs(y):
		y = 0
	if blocked(rays_positive_x) and x > 0:
		x = 0
	if blocked(rays_negative_x) and x < 0:
		x = 0
	if blocked(rays_positive_z) and y > 0:
		y = 0
	if blocked(rays_negative_z) and y < 0:
		y = 0
	x = clamp(round(x), -1, 1)
	y = clamp(round(y), -1, 1)
	return Vector2(x, y)

func blocked(rays: Spatial) -> bool:
	for r in rays.get_children():
		if r.is_colliding():
			return true
	return false

func _push() -> void:
	var t = global_translation
	if !pushing and (dir.x != 0 or dir.y != 0):
		pushing = true
		play_sound_pushed()
		anim_tween.interpolate_property(self, "global_translation:x", t.x, t.x + dir.x, 1.0, Tween.TRANS_CUBIC, Tween.EASE_OUT)
		anim_tween.interpolate_property(self, "global_translation:z", t.z, t.z + dir.y, 1.0, Tween.TRANS_CUBIC, Tween.EASE_OUT)
		anim_tween.start()
#		yield(get_tree().create_timer(0.4), "timeout")
#		if !collider:
#			play_sound_stop()
	yield(anim_tween, "tween_completed")
	pushing = false

func play_sound_pushed() -> void:
	pass

func play_sound_stop() -> void:
	pass

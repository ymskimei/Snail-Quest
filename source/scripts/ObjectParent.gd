class_name ObjectParent
extends RigidBody

onready var anim: AnimationPlayer = $AnimationPlayer
onready var anim_tween: Tween = $Tween

#func ready() -> void:
	#anim = get_node_or_null("AnimationPlayer")
	#anim_tween = get_node_or_null("Tween")

func get_coords(raw: bool = false) -> Vector3:
	var x = global_transform.origin.x
	var y = global_transform.origin.y
	var z = global_transform.origin.z
	if !raw:
		x = round(x)
		y = round(y)
		z = round(z)
	var coords = [x, y, z]
	return coords

func set_coords(position: Vector3, angle: String = "Default") -> void:
	set_global_translation(position)
	if !angle == "Default":
		set_global_rotation(Vector3(0, deg2rad(MathHelper.cardinal_to_degrees(angle)), 0))

func is_controllable() -> bool:
	if GlobalManager.controllable == self:
		return true
	return false

extends RigidBody

func _ready() -> void:
	connect("body_entered", self, "_on_RigidBody_body_entered")
#
#func _on_RigidBody_body_entered(body):
#	if body.is_in_group("damage"):
#		apply_central_impulse((get_global_translation() - body.get_global_translation().normalized() * 0.1))

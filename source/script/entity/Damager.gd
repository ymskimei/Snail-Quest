extends Area

onready var mesh: MeshInstance = $MeshInstance
onready var collision: CollisionShape = $CollisionShape

var damage_amount: float = 1.0

func _ready():
	var damage_timer: Timer = Timer.new()
	damage_timer.set_wait_time(0.05)
	damage_timer.connect("timeout", self, "_on_timer")
	add_child(damage_timer)
	damage_timer.start()

func _on_Damager_body_entered(body):
	if body is RigidBody:
		var direction: Vector3 = (body.get_global_translation() - get_global_translation()).normalized()
		body.apply_central_impulse((direction + (Vector3.UP * 1.35)) * 10)

	if body is Snail and body != SnailQuest.get_controlled():
		body.play_sound_slap()

		var fake_snail = Utility.kinematic_to_physics_body(body)
		body.get_parent().add_child(fake_snail)
		fake_snail.set_global_translation(body.get_global_translation())
		fake_snail.set_global_rotation(Vector3(0, body.get_rotation_degrees().y, 0))
		body.queue_free()

		var direction: Vector3 = (fake_snail.get_global_translation() - get_global_translation()).normalized()
		fake_snail.apply_central_impulse((direction + (Vector3.UP * 5.5)) * 2)

func _on_timer() -> void:
	queue_free()

func set_damage_amount(amount: float) -> void:
	damage_amount = amount

func get_damage_amount() -> float:
	return damage_amount



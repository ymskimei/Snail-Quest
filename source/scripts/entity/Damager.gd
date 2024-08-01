extends KinematicBody

onready var mesh: MeshInstance = $MeshInstance
onready var collision: CollisionShape = $CollisionShape

var damage_amount: float = 1.0

func _ready():
	var damage_timer: Timer = Timer.new()
	damage_timer.set_wait_time(0.05)
	damage_timer.connect("timeout", self, "_on_timer")
	add_child(damage_timer)
	damage_timer.start()

func _physics_process(delta: float):
	for i in get_slide_count():
		var c = get_slide_collision(i)
		if c.collider is RigidBody:
			c.collider.apply_central_impulse(-c.normal * delta)

func _on_timer() -> void:
	queue_free()

func set_damage_amount(amount: float) -> void:
	damage_amount = amount

func get_damage_amount() -> float:
	return damage_amount

extends RigidBody

onready var anim: AnimationPlayer = $AnimationPlayer
onready var sprite: Sprite3D = $Sprite3D

func _physics_process(delta: float) -> void:
	if SB.camera:
		sprite.look_at(SB.camera.global_translation, Vector3.UP)

func _integrate_forces(state: PhysicsDirectBodyState):
	add_central_force(Vector3(-2, 0, 0))

func fade_away() -> void:
	anim.play("FadeAway")
	yield(anim, "animation_finished")
	queue_free()

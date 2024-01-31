extends RigidBody3D

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite3D = $Sprite3D

func _physics_process(_delta: float) -> void:
	if SB.camera:
		sprite.look_at(SB.camera.global_position, Vector3.UP)

func _integrate_forces(_state: PhysicsDirectBodyState3D):
	apply_central_force(Vector3(-2, 0, 0))

func fade_away() -> void:
	anim.play("FadeAway")
	await anim.animation_finished
	queue_free()

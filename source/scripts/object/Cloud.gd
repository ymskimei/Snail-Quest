extends RigidBody

onready var anim: AnimationPlayer = $AnimationPlayer
onready var sprite: Sprite3D = $Sprite3D

func _physics_process(delta: float) -> void:
	if is_instance_valid(GlobalManager.camera):
		sprite.look_at(GlobalManager.camera.global_translation, Vector3.UP)

func fade_away() -> void:
	anim.play("FadeAway")
	yield(anim, "animation_finished")
	queue_free()

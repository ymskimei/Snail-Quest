extends RigidBody

onready var modulate: CanvasModulate = $Viewport/CanvasModulate
onready var anim: AnimationPlayer = $AnimationPlayer

func fade_away() -> void:
	anim.play("FadeAway")
	yield(anim, "animation_finished")
	queue_free()

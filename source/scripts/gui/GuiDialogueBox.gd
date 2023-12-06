extends TextureRect

onready var anim: AnimationPlayer = $AnimationPlayer

func _ready():
	anim.play("Appear")
	yield(anim, "animation_finished")
	anim.play("Skew")

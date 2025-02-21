extends KinematicBody

func _ready():
	$AnimationPlayer.play("OctoMove")

func _physics_process(delta: float) -> void:
	move_and_slide_with_snap(Vector3.DOWN * 5, Vector3.UP, Vector3.UP, true, 4, deg2rad(45), false)

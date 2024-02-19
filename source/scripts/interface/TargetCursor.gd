extends Spatial

onready var cursor: Sprite3D = $SpriteCursor
onready var circle: Sprite3D = $SpriteCircle
onready var anim_cursor: AnimationPlayer = $AnimationCursor

func _ready() -> void:
	anim_cursor.play("TargetCursorAppear")
	yield(anim_cursor, "animation_finished")
	anim_cursor.play("TargetCursorBounce")

func _physics_process(delta: float):
	if is_instance_valid(SB.controlled) and SB.controlled.all_targets.size() > 0: 
		var targ = SB.controlled.all_targets[0]
		global_transform.origin = targ.global_transform.origin

		if targ.mesh:
			global_transform.origin.y = targ.mesh.get_aabb().size.y
			circle.global_transform.origin.y = 0.1

		circle.rotation_degrees.z += 60 * delta

		if SB.controlled.target:
			cursor.modulate = lerp(cursor.modulate, Color("FF4646"), 12 * delta)
			cursor.opacity = lerp(cursor.opacity, 1.0, 10 * delta)
			circle.opacity = lerp(circle.opacity, 0.5, 10 * delta)
		else:
			cursor.modulate = lerp(cursor.modulate, Color("FFFFFF"), 12 * delta)
			cursor.opacity = lerp(cursor.opacity, 0.5, 10 * delta)
			circle.opacity = lerp(circle.opacity, 0.0, 10 * delta)

#func delete() -> void:
#	anim_cursor.play_backwards("TargetCursorAppear")
#	yield(anim_cursor, "animation_finished")
#	queue_free()

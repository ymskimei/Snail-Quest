extends Spatial

onready var cursor: Sprite3D = $SpriteCursor
onready var anim_cursor: AnimationPlayer = $AnimationCursor

func _ready() -> void:
	anim_cursor.play("TargetCursorAppear")
	yield(anim_cursor, "animation_finished")
	anim_cursor.play("TargetCursorBounce")

func _physics_process(delta: float):
	if is_instance_valid(SnailQuest.get_controlled()) and "all_targets" in SnailQuest.get_controlled():
		if SnailQuest.get_controlled().all_targets.size() > 0: 
			var targ = SnailQuest.get_controlled().all_targets[0]
			if SnailQuest.get_controlled().targeting:
				targ = SnailQuest.get_controlled().target

				if is_instance_valid(targ):
					set_global_translation(targ.get_global_translation())
					if targ.mesh:
						global_translation.y += targ.mesh.get_aabb().size.y
					rotation_degrees = targ.rotation_degrees

			if SnailQuest.get_controlled().target:
				cursor.modulate = lerp(cursor.modulate, Color("FF4646"), 12 * delta)
				cursor.opacity = lerp(cursor.opacity, 1.0, 10 * delta)
			else:
				cursor.modulate = lerp(cursor.modulate, Color("FFFFFF"), 12 * delta)
				cursor.opacity = lerp(cursor.opacity, 0.5, 10 * delta)

#func delete() -> void:
#	anim_cursor.play_backwards("TargetCursorAppear")
#	yield(anim_cursor, "animation_finished")
#	queue_free()

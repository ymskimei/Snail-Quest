extends Node3D

@onready var cursor: Sprite3D = $SpriteCursor
@onready var circle: Sprite3D = $SpriteCircle
@onready var anim_cursor: AnimationPlayer = $AnimationCursor

func _ready() -> void:
#	anim_cursor.play("TargetCursorAppear")
#	yield(anim_cursor, "animation_finished")
	anim_cursor.play("TargetCursorBounce")

func _physics_process(delta: float):
	if is_instance_valid(SB.controlled) and SB.controlled is Entity: 
		var p = SB.controlled
		if SB.controlled.target:
			global_position = p.target.global_position
			if p.target.mesh:
				global_position.y = p.target.mesh.get_aabb().size.y
				circle.global_position.y = 0.1
		circle.rotation_degrees.z += 60 * delta
		if SB.controlled.can_target:
			cursor.modulate = lerp(cursor.modulate, Color("FF4646"), 12 * delta)
			cursor.transparency = lerp(cursor.transparency, 1.0, 10 * delta)
			circle.transparency = lerp(circle.transparency, 0.5, 10 * delta)
		else:
			cursor.modulate = lerp(cursor.modulate, Color("FFFFFF"), 12 * delta)
			cursor.transparency = lerp(cursor.transparency, 0.5, 10 * delta)
			circle.transparency = lerp(circle.transparency, 0.0, 10 * delta)

#func delete() -> void:
#	anim_cursor.play_backwards("TargetCursorAppear")
#	yield(anim_cursor, "animation_finished")
#	queue_free()

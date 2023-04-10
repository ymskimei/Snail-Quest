extends Spatial

signal goto_room(room)
signal goto_main

func _on_Area_body_entered(body : PhysicsBody, room_path : String):
	if body is Player:
		emit_signal("goto_room", load(room_path))

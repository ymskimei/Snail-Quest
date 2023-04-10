extends Spatial

export(String) var room_path

signal goto_room(room)
signal goto_main

func _on_Area_body_entered(body : PhysicsBody):
	emit_signal("goto_room", load(room_path))

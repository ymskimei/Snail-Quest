class_name Warp
extends Node3D

@export var resource: Resource

signal goto_room(room, coords, dir)

func _on_Area_body_entered(body : PhysicsBody3D):
	if body is Interactable and body.is_controlled():
		emit_signal("goto_room", load(resource.room_path), resource.coordinates, resource.coordinates)

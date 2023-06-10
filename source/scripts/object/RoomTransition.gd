class_name RoomTransition
extends Spatial

export(Resource) var resource

onready var room_path : String
onready var coordinates : Vector3
onready var direction : String

signal goto_room(room, coords, dir)

func _ready():
	room_path = resource.room_path
	coordinates = resource.coordinates
	direction = resource.direction
	
func _on_Area_body_entered(body : PhysicsBody):
	if body is Player:
		print("test")
		emit_signal("goto_room", load(room_path), coordinates, direction)

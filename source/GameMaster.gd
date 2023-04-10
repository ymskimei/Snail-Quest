extends Node

signal game_end

var room_first = preload("res://assets/world/dev/test_room_2.tscn").instance() 
var room_current : Spatial

func _ready():
	room_current = room_first
	$Rooms.add_child(room_current)
	print(room_current)
	room_current.connect("goto_room", self, "_on_Goto_Room")
	room_current.connect("goto_main", self, "_on_Goto_Main")

func _on_Goto_Room(room : PackedScene):
	get_tree().set_deferred("paused", true)
	var room_new = room.instance()
	$Rooms.add_child(room_new)
	room_current.queue_free()
	room_current = room_new
	room_new.connect("goto_room", self, "_on_goto_room")
	room_new.connect("goto_main", self, "_on_goto_main")
	get_tree().set_deferred("paused", false)

func _on_Goto_Main():
	get_tree().set_deferred("paused", true)
	emit_signal("game_end")

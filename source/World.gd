extends Node

signal game_end

var room_first = preload("res://assets/world/dev/test_room_2.tscn").instance() 
var room_current : Spatial

func _ready():
	$GuiTransition/AnimationPlayer.play_backwards("GuiTransitionFade")
	room_current = room_first
	$Rooms.add_child(room_current)
	check_for_transitions(room_current)
	GlobalManager.game_time.set_time(480) #temporary time set

func _on_goto_room(room : PackedScene, coords : Vector3, dir : String):
	get_tree().set_deferred("paused", true)
	$GuiTransition/AnimationPlayer.play("GuiTransitionFade")
	yield($GuiTransition/AnimationPlayer, "animation_finished")
	var room_new = room.instance()
	$Rooms.add_child(room_new)
	room_current.queue_free()
	room_current = room_new
	check_for_transitions(room_current)
	GlobalManager.player.set_coords(coords, dir)
	GlobalManager.camera.set_coords(coords, dir, true)
	$GuiTransition/AnimationPlayer.play_backwards("GuiTransitionFade")
	get_tree().set_deferred("paused", false)

func _on_goto_main():
	get_tree().set_deferred("paused", true)
	emit_signal("game_end")

func check_for_transitions(room):
	for child in room.find_node("Transitions").get_children():
		if child is RoomTransition:
			child.connect("goto_room", self, "_on_goto_room")
			child.connect("goto_main", self, "_on_goto_main")

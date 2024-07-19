extends Node

export var resource: Resource = null

onready var rooms: Spatial = $Rooms

signal game_end
signal room_loaded

func _ready() -> void:
	SnailQuest.set_world(self)
	for c in Network.controlled_instances.size():
		var controlled = Network.controlled_instances[c]
		add_child(controlled)
		if controlled.is_network_master():
			SnailQuest.set_controlled(controlled)
	_on_goto_room(load(resource.room_path), resource.coordinates, resource.direction, false, false)

func load_room(room: PackedScene, coords: Vector3, dir: String, keep_rooms: bool = false) -> void:
	if is_instance_valid(room):
		var new_room = room.instance()
		if !keep_rooms:
			for r in rooms.get_children():
				rooms.remove_child(r)
		rooms.add_child(new_room)
		for s in get_children():
			if s is Entity:
				print("test")
				s.set_coords(coords, dir)
		SnailQuest.camera.set_coords(coords, dir, true)
		_get_warps(new_room)
		emit_signal("room_loaded")

func _on_goto_main() -> void:
	get_tree().set_deferred("paused", true)
	emit_signal("game_end")

func _on_goto_room(room: PackedScene, coords: Vector3, dir: String, pause: bool = true, fade_in: bool = true) -> void:
	if pause:
		get_tree().set_deferred("paused", true)
	if fade_in:
		Interface.transition.play("GuiTransitionFade")
		yield(Interface.transition, "animation_finished")
	load_room(room, coords, dir)
	yield(self, "room_loaded")
	Interface.transition.play_backwards("GuiTransitionFade")
	yield(Interface.transition, "animation_finished")
	if get_tree().paused:
		get_tree().set_deferred("paused", false)

func _get_warps(room: Spatial) -> void:
	if is_instance_valid(room.find_node("Warps")):
		for child in room.find_node("Warps").get_children():
			if child is Warp:
				child.connect("goto_room", self, "_on_goto_room")

func get_rooms() -> Spatial:
	return rooms

extends Node

signal game_end

var room_first = preload("res://assets/world/chunktest/chunk.tscn").instance() 
var room_current : Spatial

var start_chunk = preload("res://assets/world/chunktest/chunk.tscn") 

export var render_distance = 3
export var chunk_size = 16
var current_chunk = Vector3()
var previous_chunk = Vector3()
var loaded_chunk : bool

export var circumnav : bool
export var rev_distance = 4

onready var active_coord = []
onready var active_chunks = []

func _ready():
	$GuiTransition/AnimationPlayer.play_backwards("GuiTransitionFade")
	room_current = room_first
	$Rooms.add_child(room_current)
	check_for_transitions(room_current)
	GlobalManager.game_time.set_time(480) #temporary time set
	
	current_chunk = _get_player_chunk(GlobalManager.player.global_translation)
	load_chunk()

func _process(_delta):
	current_chunk =  _get_player_chunk(GlobalManager.player.global_translation)
	if previous_chunk != current_chunk:
		if !loaded_chunk:
			load_chunk()
	else:
		loaded_chunk = false
	previous_chunk = current_chunk

func _get_player_chunk(pos):
	var chunk_pos = Vector3()
	chunk_pos.x = int(pos.x / chunk_size)
	chunk_pos.z = int(pos.z / chunk_size)
	if pos.x < 0:
		chunk_pos.x -= 1
	if pos.z < 0:
		chunk_pos.z -= 1
	return chunk_pos
	
func load_chunk():
	var render_bounds = (float(render_distance) * 2.0) + 1.0
	var loaded_coord = []
	for x in range(render_bounds):
		for z in range (render_bounds):
			var _x = (x + 1) - (round(render_bounds / 2.0)) + current_chunk.x
			var _z = (z + 1) - (round(render_bounds / 2.0)) + current_chunk.z
			var chunk_coords = Vector3(_x, 0, _z)
			var chunk_key = _get_chunk_key(chunk_coords)
			loaded_coord.append(chunk_coords)
			if active_coord.find(chunk_coords) == -1:
				var chunk = start_chunk.instance()
				chunk.translation = chunk_coords * chunk_size
				active_chunks.append(chunk)
				active_coord.append(chunk_coords)
				chunk.start(chunk_key)
				add_child(chunk)
	var delete_chunks = []
	for x in active_coord:
		if loaded_coord.find(x) == -1:
			delete_chunks.append(x)
	for x in delete_chunks:
		var index = active_coord.find(x)
		active_chunks[index].save()
		active_chunks.remove(index)
		active_coord.remove(index)

func _get_chunk_key(coords : Vector3):
	var key = coords
	if !circumnav:
		return key
	key.x = wrapf(coords.x, -rev_distance, rev_distance + 1)
	return key

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
	if is_instance_valid(room.find_node("Transitions")):
		for child in room.find_node("Transitions").get_children():
			if child is RoomTransition:
				child.connect("goto_room", self, "_on_goto_room")
				child.connect("goto_main", self, "_on_goto_main")



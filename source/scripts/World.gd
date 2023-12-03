extends Node

signal game_end

#Irrelevant for now, they relate to the previous scene transitioning
var room_first = preload("res://source/scenes/world/dev/world_test.tscn")
var room_current : Spatial

#Scene for the chunk junk
var world = "res://source/scenes/world/chunktest/"

#Temporary variables for testing
export var render_radius = 1

var player_pos : Vector3

var all_chunks: Dictionary = {} # Dictionary of all chunks { Vector2 : Chunk }
var current_instances: Dictionary = {} # Dictionary of instances { Vector2 : Instance }
var current_chunks = [] # All currently existing chunk  / Array[Vector3]

func _ready():
	$GuiTransition/AnimationPlayer.play_backwards("GuiTransitionFade")
	room_current = room_first.instance() 
	$Rooms.add_child(room_current)
	check_for_transitions(room_current)
	GlobalManager.game_time.set_time(480) #temporary time set
	register_chunks()

#The chunk stuff initiates here
func register_chunks():
	# TODO: End up doing this in the get_chunks_row method
	# wasn't sure if you wanted to continue the folder thing, so didn't refactor
	var arr = get_chunk_rows(world)
	for row in arr:
		for chunk in row:
			all_chunks[chunk.chunk_coord] = chunk

func _process(_delta):
	load_chunks()
	pass

# TODO: Eventually add in 2nd parameter to update data (like entities locations)
func add_chunk(chunk: Chunk):
	var instance = chunk.resource.instance()
	instance.translation = chunk.real_pos()

	current_instances[chunk.chunk_coord] = instance
	add_child(instance)

func difference(arr1, arr2):
	var only_in_arr1 = []
	for v in arr1:
		if not (v in arr2):
			only_in_arr1.append(v)
	return only_in_arr1

func load_chunks():
	var current_chunk = _get_player_chunk(GlobalManager.player.global_translation)
	var new_current = {} # Being a dictionary means we don't have duplicates

	for x in range(render_radius):
		for z in range(render_radius):
			if pow(x, 2) + pow(z, 2) < pow(render_radius, 2):
				new_current[Vector2(+x+current_chunk.x, +z+current_chunk.y)] = null
				new_current[Vector2(+x+current_chunk.x, -z+current_chunk.y)] = null
				new_current[Vector2(-x+current_chunk.x, +z+current_chunk.y)] = null
				new_current[Vector2(-x+current_chunk.x, -z+current_chunk.y)] = null
			
	for pos in difference(current_chunks, new_current.keys()): # only in current / remove
		if current_instances.has(pos):
			var instance = current_instances[pos]
			current_instances.erase(pos)
			instance.queue_free()

	for pos in difference(new_current.keys(), current_chunks): # only in new / add
		if all_chunks.has(pos):
			var chunk = all_chunks[pos]
			add_chunk(chunk)

	current_chunks.clear()
	current_chunks.append_array(new_current.keys())

#I did this part last night and I think it probably works or something
func _get_player_chunk(pos):
	var coords_x = floor(pos.x / GlobalManager.chunk_size)
	var coords_z = floor(pos.z / GlobalManager.chunk_size)
	var chunk_coords = Vector2(coords_x, coords_z)
	return chunk_coords

#Self explanatory
func get_chunk_rows(path : String) -> Array:
	var rows_array = []
	var directory = Directory.new()
	directory.open(path)
	directory.list_dir_begin()
	var row_name = directory.get_next()
	while row_name != "":
		var row_path = path + "/" + row_name
		if directory.current_is_dir() and !row_name.begins_with("."):
			var row_segments = []
			var row = Directory.new()
			row.open(row_path)
			row.list_dir_begin()
			var file_name = row.get_next()
			while file_name != "":
				var file_path = row_path + "/" + file_name
				if !row.current_is_dir():
					# Must add 1 because folder structure starts with index 1 
					var segment = Chunk.new(Vector2(rows_array.size()+1, row_segments.size()+1), load(file_path))
					row_segments.append(segment)
				file_name = row.get_next()
			rows_array.append(row_segments)
		row_name = directory.get_next()
	directory.list_dir_end()
	return rows_array

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

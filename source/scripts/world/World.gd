extends Node

export var resource: Resource = null

onready var anim: AnimationPlayer = $GuiTransition/AnimationPlayer
onready var rooms: Spatial = $Rooms

export var render_radius: int = 1 #Temporary variables for testing

var all_chunks: Dictionary = {} # Dictionary of all chunks { Vector2 : Chunk }
var current_instances: Dictionary = {} # Dictionary of instances { Vector2 : Instance }
var current_chunks = [] # All currently existing chunk  / Array[Vector3]

signal game_end
signal room_loaded

func _ready() -> void:
	Auto.game_time.set_time(480) #Temporary time set
	Auto.set_controlled($Player1) #Temporary player set
	Auto.set_world(self)
	_on_goto_room(load(resource.room_path), resource.coordinates, resource.direction, false, false)
	_register_chunks()

func _process(_delta: float) -> void:
	if is_instance_valid(Auto.controlled):
		_load_chunks()

func load_room(room: PackedScene, coords: Vector3, dir: String, keep_rooms: bool = false) -> void:
	if is_instance_valid(room):
		var new_room = room.instance()
		if !keep_rooms:
			for r in rooms.get_children():
				rooms.remove_child(r)
		rooms.add_child(new_room)
		_register_chunks()
		Auto.controlled.set_coords(coords, dir)
		Auto.camera.set_coords(coords, dir, true)
		_get_warps(new_room)
		emit_signal("room_loaded")

func _on_goto_main() -> void:
	get_tree().set_deferred("paused", true)
	emit_signal("game_end")

func _on_goto_room(room: PackedScene, coords: Vector3, dir: String, pause: bool = true, fade_in: bool = true) -> void:
	if pause:
		get_tree().set_deferred("paused", true)
	if fade_in:
		anim.play("GuiTransitionFade")
		yield(anim, "animation_finished")
	load_room(room, coords, dir)
	yield(self, "room_loaded")
	anim.play_backwards("GuiTransitionFade")
	yield(anim, "animation_finished")
	if get_tree().paused:
		get_tree().set_deferred("paused", false)

func _get_warps(room: Spatial) -> void:
	if is_instance_valid(room.find_node("Warps")):
		for child in room.find_node("Warps").get_children():
			if child is Warp:
				child.connect("goto_room", self, "_on_goto_room")

#The chunk stuff initiates here
func _register_chunks() -> void:
	# TODO: End up doing this in the get_chunks_row method
	# wasn't sure if you wanted to continue the folder thing, so didn't refactor
	var arr = _get_chunk_rows(Auto.scene["world"] + "chunktest")
	for row in arr:
		for chunk in row:
			all_chunks[chunk.chunk_coord] = chunk

# TODO: Eventually add in 2nd parameter to update data (like entities locations)
func _add_chunk(chunk: Chunk) -> void:
	var instance = chunk.resource.instance()
	instance.translation = chunk.real_pos()
	current_instances[chunk.chunk_coord] = instance
	add_child(instance)

func _difference(arr1: Array, arr2: Array) -> Array:
	var only_in_arr1 = []
	for v in arr1:
		if not (v in arr2):
			only_in_arr1.append(v)
	return only_in_arr1

func _load_chunks() -> void:
	var current_chunk = _get_controlled_chunk(Auto.controlled.global_translation)
	var new_current = {} # Being a dictionary means we don't have duplicates
	for x in range(render_radius):
		for z in range(render_radius):
			if pow(x, 2) + pow(z, 2) < pow(render_radius, 2):
				new_current[Vector2(+x+current_chunk.x, +z+ current_chunk.y)] = null
				new_current[Vector2(+x+current_chunk.x, -z+ current_chunk.y)] = null
				new_current[Vector2(-x+current_chunk.x, +z+ current_chunk.y)] = null
				new_current[Vector2(-x+current_chunk.x, -z+ current_chunk.y)] = null
	for pos in _difference(current_chunks, new_current.keys()): # only in current / remove
		if current_instances.has(pos):
			var instance = current_instances[pos]
			current_instances.erase(pos)
			instance.queue_free()
	for pos in _difference(new_current.keys(), current_chunks): # only in new / add
		if all_chunks.has(pos):
			var chunk = all_chunks[pos]
			_add_chunk(chunk)
	current_chunks.clear()
	current_chunks.append_array(new_current.keys())

#Self explanatory
func _get_chunk_rows(path: String) -> Array:
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

#I did this part last night and I think it probably works or something
func _get_controlled_chunk(pos: Vector3) -> Vector2:
	var coords_x = floor(pos.x / Auto.chunk_size)
	var coords_z = floor(pos.z / Auto.chunk_size)
	var chunk_coords = Vector2(coords_x, coords_z)
	return chunk_coords

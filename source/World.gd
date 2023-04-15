extends Node

signal game_end

#Irrelevant for now, they relate to the previous scene transitioning
var room_first = preload("res://assets/world/chunkworld.tscn")
var room_current : Spatial

#Scene for the chunk junk
var world = "res://assets/world/chunktest"

#Temporary variables for testing
export var grid_size = Vector2(4, 4)
export var chunk_size = 64
export var render_distance = 1

var player_pos : Vector3

var all_chunks = [] #2D array of chunks for the grid
var current_chunks = [] #All currently existing chunks

func _ready():
	$GuiTransition/AnimationPlayer.play_backwards("GuiTransitionFade")
	room_current = room_first.instance() 
	$Rooms.add_child(room_current)
	check_for_transitions(room_current)
	GlobalManager.game_time.set_time(480) #temporary time set
	register_chunks()

#The chunk stuff initiates here
func register_chunks():
	all_chunks = get_chunk_rows(world)
	var grid_center = grid_size / 2
	GlobalManager.register_chunk_start(Vector3(-grid_center.x, 0, -grid_center.y))
	for x in range(-grid_center.x, grid_center.x):
		for z in range(-grid_center.y, grid_center.y):
			var scene_name = all_chunks[x + grid_size.x / 2][z + grid_size.y / 2]
			var instance = scene_name
			instance.translation = (Vector3(x, 0, z) * chunk_size) + Vector3(chunk_size, 0, chunk_size) / 2
			add_child(instance)
			current_chunks.append(instance)

func _process(_delta):
	load_chunks()

func load_chunks():
	var player_position = GlobalManager.player.global_translation
	var current_chunk = _get_player_chunk(player_position)
	
	var render_bounds = (float(render_distance) * 2.0) + 1.0
	var loaded_coord = []
	for x in range(all_chunks.size()):
		for z in range(all_chunks[x].size()):
			var _x = (x + 1) - (round(render_bounds / 2.0)) + current_chunk.x
			var _z = (z + 1) - (round(render_bounds / 2.0)) + current_chunk.z
			var chunk_coords = Vector3(_x, 0, _z)
			loaded_coord.append(chunk_coords)
			var chunk = all_chunks[x][z]
			if is_instance_valid(chunk):
				var distance = player_position.distance_to(chunk.translation) / chunk_size
				
				#This works but since the chunks don't exist anymore, they can't return afterward \/
#				if distance > render_distance and chunk.is_inside_tree():
#					print(distance)
#					chunk.queue_free()
#					all_chunks[x][z] = null

				#This was a result of one of my tries to store the chunks to use for re-instancing \/
#				if distance <= render_distance and !instance.is_inside_tree():
#					var new_instance = instance
#					if new_instance == null:
#						new_instance = instance
#					new_instance.position = instance.position
#					active_chunks.append(instance)
#					active_coord.append(chunk_coords)
#					add_child(new_instance)
#					all_chunks[x][z] = new_instance

#I did this part last night and I think it probably works or something
func _get_player_chunk(pos):
	var chunk_pos = Vector3()
	chunk_pos.x = int(pos.x / chunk_size)
	chunk_pos.z = int(pos.z / chunk_size)
	if pos.x < 0:
		chunk_pos.x -= 1
	if pos.z < 0:
		chunk_pos.z -= 1
	return chunk_pos

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
					var segment = load(file_path).instance()
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



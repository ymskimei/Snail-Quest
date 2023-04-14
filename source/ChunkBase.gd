extends Node

var chunk_coords = Vector3()
var chunk_data = []

func start(_chunk_coords):
	chunk_coords = _chunk_coords
	if WorldSave.loaded_coords.find(_chunk_coords) == -1:
		WorldSave.add_chunk(chunk_coords)
	else:
		chunk_data = WorldSave.get_data(chunk_coords)

func save():
	WorldSave.save_chunk(chunk_coords, chunk_data)
	queue_free()

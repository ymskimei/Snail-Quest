extends Node

var loaded_coords = []
var chunk_data = []

func add_chunk(coords):
	loaded_coords.append(coords)
	chunk_data.append([])

func save_chunk(coords, data):
	chunk_data[loaded_coords.find(coords)] = data

func get_data(coords):
	var data = chunk_data[loaded_coords.find(coords)]
	return data

func retrive_data(coords):
	var data = chunk_data[loaded_coords.find(coords)]
	return data

extends Node

var loaded_coords = []
var chunk_data = []

#These are leftover from trying someone else's method, I ditched it because-
#I wasn't following enough and I want to understand the code in this project, obviously.

func add_chunk(coords):
	loaded_coords.append(coords)
	chunk_data.append([])

func save_chunk(coords, data):
	chunk_data[loaded_coords.find(coords)] = data

func get_data(coords):
	var data = chunk_data[loaded_coords.find(coords)]
	return data

extends Node

const data_path: String = "user://data/"
const file_type: String = "." + "sus"
const encryption: String = "J051949"

var data_file_0: String = data_path + "data_0" + file_type
var data_file_1: String = data_path + "data_1" + file_type
var data_file_2: String = data_path + "data_2" + file_type
var data_file_3: String = data_path + "data_3" + file_type

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_save"):
		save_data(data_file_0)
	if event.is_action_pressed("debug_load"):
		load_data(data_file_0)

func save_data(d: String) -> void:
	var data = _set_save_data()
	var dir = Directory.new()
	if !dir.dir_exists(data_path):
		dir.make_dir(data_path)
	var file = File.new()
	var open_file = file.open_encrypted_with_pass(d, File.WRITE, encryption)
	if open_file == OK:
		file.store_var(data)
		file.close()

func load_data(d) -> void:
	var file = File.new()
	if file.file_exists(d):
		var open_file = file.open_encrypted_with_pass(d, File.READ, encryption)
		if open_file == OK:
			var data = file.get_var()
			_set_load_data(data)
			file.close()

func _set_save_data() -> Dictionary:
	var data: Dictionary = {
		"position": SB.controllable.global_translation,
		"rotation": SB.controllable.global_rotation,
		"max_health": SB.controllable.health,
		"health": SB.controllable.health,
		"inventory": SB.controllable.equipped.items,
		"play_time": SB.play_time.played_time,
		"game_time": SB.game_time.game_time
	}
	return data

func _set_load_data(data) -> void:
		SB.controllable.global_translation = data["position"]
		SB.controllable.global_rotation = data["rotation"]
		SB.controllable.max_health = data["max_health"]
		SB.controllable.health = data["health"]
		SB.controllable.equipped.items = data["inventory"]
		SB.play_time.played_time = data["play_time"]
		SB.game_time.game_time = data["game_time"]

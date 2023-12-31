extends Node

const data_path: String = "user://data/"
const file_type: String = "." + "sus"
const encryption_key: String = "J051949"

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
	var data = {
		"position": SnailQuest.controllable.global_translation,
		"rotation": SnailQuest.controllable.global_rotation,
		"max_health": SnailQuest.controllable.health,
		"health": SnailQuest.controllable.health,
		"inventory": SnailQuest.controllable.equipped.items,
		"play_time": SnailQuest.play_time.played_time,
		"game_time": SnailQuest.game_time.game_time
	}
	var dir = Directory.new()
	if !dir.dir_exists(data_path):
		dir.make_dir(data_path)
	var file = File.new()
	var open_file = file.open_encrypted_with_pass(d, File.WRITE, encryption_key)
	if open_file == OK:
		file.store_var(data)
		file.close()

func load_data(d) -> void:
	var file = File.new()
	if file.file_exists(d):
		var open_file = file.open_encrypted_with_pass(d, File.READ, encryption_key)
		if open_file == OK:
			var data = file.get_var()
			SnailQuest.controllable.global_translation = data["position"]
			SnailQuest.controllable.global_rotation = data["rotation"]
			SnailQuest.controllable.max_health = data["max_health"]
			SnailQuest.controllable.health = data["health"]
			SnailQuest.controllable.equipped.items = data["inventory"]
			SnailQuest.play_time.played_time = data["play_time"]
			SnailQuest.game_time.game_time = data["game_time"]
			file.close()

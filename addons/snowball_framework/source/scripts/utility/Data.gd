extends Node

const data_path: String = "user://data/"
const image_path: String = "user://screenshots/"
const file_type: String = "." + "sus"
const encryption: String = "J051949"

var data_file_0: String = data_path + "data_0" + file_type
var data_file_1: String = data_path + "data_1" + file_type
var data_file_2: String = data_path + "data_2" + file_type
var data_file_3: String = data_path + "data_3" + file_type

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(Device.debug_save):
		save_data(data_file_0)
	if event.is_action_pressed(Device.debug_load):
		load_data(data_file_0)
	if event.is_action_pressed(Device.screenshot):
		save_screenshot()

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
		"position": SB.controlled.global_translation,
		"rotation": SB.controlled.global_rotation,
		"max_health": SB.controlled.health,
		"health": SB.controlled.health,
		"inventory": SB.controlled.equipped.items,
		"play_time": SB.play_time.played_time,
		"game_time": SB.game_time.game_time
	}
	return data

func _set_load_data(data) -> void:
		SB.controlled.global_translation = data["position"]
		SB.controlled.global_rotation = data["rotation"]
		SB.controlled.max_health = data["max_health"]
		SB.controlled.health = data["health"]
		SB.controlled.equipped.items = data["inventory"]
		SB.play_time.played_time = data["play_time"]
		SB.game_time.game_time = data["game_time"]

func save_screenshot() -> void:
	var time: String = Time.get_date_string_from_system() + "_" + Time.get_time_string_from_system().replace(":", "_")
	var count: int = 0
	var extension: String = ".png"
	var dir = Directory.new()
	if !dir.dir_exists(image_path):
		dir.make_dir(image_path)
	var image = get_screenshot()
	image.save_png(image_path + time + extension)

func get_screenshot() -> Image:
	var screen: Texture = get_viewport().get_texture()
	var image: Image = screen.get_data()
	image.flip_y()
	return image

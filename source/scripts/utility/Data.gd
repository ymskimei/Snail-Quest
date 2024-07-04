extends Node

const config_path: String = "user://settings.cfg"
const data_path: String = "user://data/"
const image_path: String = "user://screenshots/"
const file_type: String = "." + "sus"
const encryption: String = "J051949"

var data_file_0: String = data_path + "data_0" + file_type
var data_file_1: String = data_path + "data_1" + file_type
var data_file_2: String = data_path + "data_2" + file_type
var data_file_3: String = data_path + "data_3" + file_type

var config = ConfigFile.new()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(Auto.input.debug_save):
		set_data(data_file_0)
	if event.is_action_pressed(Auto.input.debug_load):
		set_data(data_file_0)
	if event.is_action_pressed(Auto.input.screenshot):
		save_screenshot()

func set_config(section: String, key: String, value) -> void:
	config.set_value(section, key, value)
	config.save(config_path)

func get_config(section: String, key: String, value):
	config.load(config_path)
	return config.get_value(section, key, value)

func set_data(d: String) -> void:
	var data = _set_save_data()
	var dir = Directory.new()
	if !dir.dir_exists(data_path):
		dir.make_dir(data_path)
	var file = File.new()
	var open_file = file.open_encrypted_with_pass(d, File.WRITE, encryption)
	if open_file == OK:
		file.store_var(data)
		file.close()

func get_data(d) -> void:
	var file = File.new()
	if file.file_exists(d):
		var open_file = file.open_encrypted_with_pass(d, File.READ, encryption)
		if open_file == OK:
			var data = file.get_var()
			_get_save_data(data)
			file.close()

func _set_save_data() -> Dictionary:
	var data: Dictionary = {
		"position": Auto.controlled.global_translation,
		"rotation": Auto.controlled.global_rotation,
		"max_health": Auto.controlled.health,
		"health": Auto.controlled.health,
		"inventory": Auto.controlled.equipped.items,
		"play_time": Auto.play_time.played_time,
		"game_time": Auto.game_time.game_time
	}
	return data

func _get_save_data(data) -> void:
		Auto.controlled.global_translation = data["position"]
		Auto.controlled.global_rotation = data["rotation"]
		Auto.controlled.max_health = data["max_health"]
		Auto.controlled.health = data["health"]
		Auto.controlled.equipped.items = data["inventory"]
		Auto.play_time.played_time = data["play_time"]
		Auto.game_time.game_time = data["game_time"]

func save_screenshot() -> void:
	var time: String = Time.get_date_string_from_system() + "_" + Time.get_time_string_from_system().replace(":", ".")
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

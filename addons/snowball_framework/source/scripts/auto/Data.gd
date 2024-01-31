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
	if event.is_action_pressed(Device.debug_save):
		set_data(data_file_0)
	if event.is_action_pressed(Device.debug_load):
		set_data(data_file_0)
	if event.is_action_pressed(Device.screenshot):
		save_screenshot()

func set_config(section: String, key: String, value) -> void:
	config.set_value(section, key, value)
	config.save(config_path)

func get_config(section: String, key: String, value):
	config.load(config_path)
	return config.get_value(section, key, value)

func set_data(d: String) -> void:
	var data = _set_save_data()
	var dir = DirAccess.open(data_path)
	if !dir:
		dir.make_dir(data_path)
	var file = FileAccess.open_encrypted_with_pass(d, FileAccess.WRITE, encryption)
	if file:
		file.store_var(data)
		file.close()

func get_data(d) -> void:
	var file = FileAccess.open_encrypted_with_pass(d, FileAccess.READ, encryption)
	if file.file_exists(d):
		if file:
			var data = file.get_var()
			_get_save_data(data)
			file.close()

func _set_save_data() -> Dictionary:
	var data: Dictionary = {
		"position": SB.controlled.global_position,
		"rotation": SB.controlled.global_rotation,
		"max_health": SB.controlled.health,
		"health": SB.controlled.health,
		"inventory": SB.controlled.equipped.items,
		"play_time": SB.play_time.played_time,
		"game_time": SB.game_time.game_time
	}
	return data

func _get_save_data(data) -> void:
		SB.controlled.global_position = data["position"]
		SB.controlled.global_rotation = data["rotation"]
		SB.controlled.max_health = data["max_health"]
		SB.controlled.health = data["health"]
		SB.controlled.equipped.items = data["inventory"]
		SB.play_time.played_time = data["play_time"]
		SB.game_time.game_time = data["game_time"]

func save_screenshot() -> void:
	var time: String = Time.get_date_string_from_system() + "_" + Time.get_time_string_from_system().replace(":", ".")
	var count: int = 0
	var extension: String = ".png"
	var dir = DirAccess.open(image_path)
	if !dir:
		dir.make_dir(image_path)
	var image = get_screenshot()
	image.save_png(image_path + time + extension)

func get_screenshot() -> Image:
	var screen: Texture2D = get_viewport().get_texture()
	var image: Image = screen.get_data()
	image.flip_y()
	return image

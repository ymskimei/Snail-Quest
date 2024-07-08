extends Node

const config_path: String = "user://settings.cfg"
const data_path: String = "user://data/"
const image_path: String = "user://screenshots/"

const file_type: String = ".sus" #super-ultra-save
const encryption: String = "J051949" #january 5th, 1949

var current_data_file: String = ""

var data_file_0: String = data_path + "data_0" + file_type
var data_file_1: String = data_path + "data_1" + file_type
var data_file_2: String = data_path + "data_2" + file_type
var data_file_3: String = data_path + "data_3" + file_type

var config = ConfigFile.new()

func _ready() -> void:
	set_current_data_file(get_data_file(0))

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(Auto.input.debug_save):
		write_data(get_current_data_file(), get_current_data())
	if event.is_action_pressed(Auto.input.debug_load):
		load_data(get_data(get_current_data_file()))
	if event.is_action_pressed(Auto.input.screenshot):
		save_screenshot()

func set_config(section: String, key: String, value) -> void:
	config.set_value(section, key, value)
	config.save(config_path)

func get_config(section: String, key: String, value):
	config.load(config_path)
	return config.get_value(section, key, value)

func set_current_data_file(data: String) -> void:
	current_data_file = data

func get_current_data_file() -> String:
	return current_data_file

func get_data_file(selection: int = 0) -> String:
	match selection:
		1:
			return data_file_1
		2:
			return data_file_2
		3:
			return data_file_3
		_:
			return data_file_0

func get_data(file_path: String) -> Dictionary:
	var file: File = File.new()
	var data: Dictionary 
	if file.file_exists(file_path):
		var open_file = file.open_encrypted_with_pass(file_path, File.READ, encryption)
		if open_file == OK:
			data = file.get_var()
			file.close()
		return data
	else:
		return create_new_data()

func write_data(new_file_path: String, data: Dictionary) -> void:
	var dir = Directory.new()
	if !dir.dir_exists(data_path):
		dir.make_dir(data_path)
	var file = File.new()
	var open_file = file.open_encrypted_with_pass(new_file_path, File.WRITE, encryption)
	if open_file == OK:
		file.store_var(data)
		file.close()

func _get_identity_as_string() -> String:
	var snail: Resource = ResourceLoader.load("res://assets/resource/identity/snail/snail.tres")
	if Auto.controlled.identity:
		snail = Auto.controlled.identity
	var string = var2str(ResourceSaver.load(snail))
	return string

func _get_resource_from_string(resource_as_string: String) -> Resource:
	var resource = ResourceSaver.load(str2var(resource_as_string))
	return resource

func get_current_data() -> Dictionary:
	var data: Dictionary = {
		"identity": Auto.controlled.identity,
		"translation": Auto.controlled.get_global_translation(),
		"rotation": Auto.controlled.get_global_rotation(),
		"game_time": Auto.game_time.get_raw_time(),
		"location": "Nowhere",
		"event_flags": ["placeholder"],
		"nearby_entities": ["placeholder"],
		"play_time": Auto.play_time.get_raw_time(),
		"last_played": Time.get_date_string_from_system() + " " + Time.get_time_string_from_system(),
	}
	return data

func create_new_data() -> Dictionary:
	var data: Dictionary = {
		"identity": ResourceLoader.load("res://assets/resource/identity/snail/snail.tres"),
		"translation": Auto.controlled.get_global_translation(),
		"rotation": Auto.controlled.get_global_rotation(),
		"game_time": 480,
		"location": "Nowhere",
		"event_flags": [],
		"nearby_entities": [],
		"play_time": 0,
		"last_played": "Never",
	}
	return data

func load_data(data: Dictionary) -> void:
	var snail = Auto.controlled
	snail.identity = data["identity"]
	snail.set_global_translation(data["translation"])
	snail.set_global_rotation(data["rotation"])
	Auto.game_time.set_raw_time(data["game_time"])
	#needs location setting
	#needs event flag setting
	#needs set entity locations
	Auto.play_time.set_raw_time(data["play_time"])
	snail.update_appearance()

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

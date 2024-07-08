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

func get_current_data() -> Dictionary:
	var snail: Resource = Auto.controlled.identity
	var data: Dictionary = {
		"entity_name": snail.get_entity_name(),
		"max_health": snail.get_max_health(),
		"health": snail.get_health(),
		"currency": snail.get_currency(),
		"keys": snail.get_keys(),
		"boss_key": snail.get_boss_key(),
		"items": snail.get_items(),
		"mesh_shell": snail.get_mesh_shell(),
		"mesh_body": snail.get_mesh_body(),
		"mesh_eye_left": snail.get_mesh_eye_left(),
		"mesh_eye_right": snail.get_mesh_eye_right(),
		"pattern_shell": snail.get_pattern_shell(),
		"pattern_body": snail.get_pattern_body(),
		"pattern_eyes": snail.get_pattern_eyes(),
		"pattern_eyelids": snail.get_pattern_eyelids(),
		"color_shell_base": snail.get_color_shell_base(),
		"color_shell_shade": snail.get_color_shell_shade(),
		"color_shell_accent": snail.get_color_shell_accent(),
		"color_body_specular": snail.get_color_body_specular(),
		"color_body_base": snail.get_color_body_base(),
		"color_body_shade": snail.get_color_body_shade(),
		"color_body_accent": snail.get_color_body_accent(),
		"color_eyes": snail.get_color_eyes(),
		"mesh_hat": snail.get_mesh_hat(),
		"pattern_hat": snail.get_pattern_hat(),
		"pattern_sticker": snail.get_pattern_sticker(),
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
	var default_snail: Resource = ResourceLoader.load("res://assets/resource/identity/snail/snail.tres")
	var data: Dictionary = {
		"entity_name": default_snail.get_entity_name(),
		"max_health": default_snail.get_max_health(),
		"health": default_snail.get_health(),
		"currency": default_snail.get_currency(),
		"keys": default_snail.get_keys(),
		"boss_key": default_snail.get_boss_key(),
		"items": default_snail.get_items(),
		"mesh_shell": default_snail.get_mesh_shell(),
		"mesh_body": default_snail.get_mesh_body(),
		"mesh_eye_left": default_snail.get_mesh_eye_left(),
		"mesh_eye_right": default_snail.get_mesh_eye_right(),
		"pattern_shell": default_snail.get_pattern_shell(),
		"pattern_body": default_snail.get_pattern_body(),
		"pattern_eyes": default_snail.get_pattern_eyes(),
		"pattern_eyelids": default_snail.get_pattern_eyelids(),
		"color_shell_base": default_snail.get_color_shell_base(),
		"color_shell_shade": default_snail.get_color_shell_shade(),
		"color_shell_accent": default_snail.get_color_shell_accent(),
		"color_body_specular": default_snail.get_color_body_specular(),
		"color_body_base": default_snail.get_color_body_base(),
		"color_body_shade": default_snail.get_color_body_shade(),
		"color_body_accent": default_snail.get_color_body_accent(),
		"color_eyes": default_snail.get_color_eyes(),
		"mesh_hat": default_snail.get_mesh_hat(),
		"pattern_hat": default_snail.get_pattern_hat(),
		"pattern_sticker": default_snail.get_pattern_sticker(),
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
	snail.identity.set_entity_name(data["entity_name"])
	snail.identity.set_max_health(data["max_health"])
	snail.identity.set_health(data["health"])
	snail.identity.set_currency(data["currency"])
	snail.identity.set_keys(data["keys"])
	snail.identity.set_boss_key(data["boss_key"])
	snail.identity.set_items(data["items"])
	snail.identity.set_mesh_shell(data["mesh_shell"])
	snail.identity.set_mesh_body(data["mesh_body"])
	snail.identity.set_mesh_eye_left(data["mesh_eye_left"])
	snail.identity.set_mesh_eye_right(data["mesh_eye_right"])
	snail.identity.set_pattern_shell(data["pattern_shell"])
	snail.identity.set_pattern_body(data["pattern_body"])
	snail.identity.set_pattern_eyes(data["pattern_eyes"])
	snail.identity.set_pattern_eyelids(data["pattern_eyelids"])
	snail.identity.set_color_shell_base(data["color_shell_base"])
	snail.identity.set_color_shell_shade(data["color_shell_shade"])
	snail.identity.set_color_shell_accent(data["color_shell_accent"])
	snail.identity.set_color_body_specular(data["color_body_specular"])
	snail.identity.set_color_body_base(data["color_body_base"])
	snail.identity.set_color_body_shade(data["color_body_shade"])
	snail.identity.set_color_body_accent(data["color_body_accent"])
	snail.identity.set_color_eyes(data["color_eyes"])
	snail.identity.set_mesh_hat(data["mesh_hat"])
	snail.identity.set_pattern_hat(data["pattern_hat"])
	snail.identity.set_pattern_sticker(data["pattern_sticker"])
	snail.update_appearance()
	snail.set_global_translation(data["translation"])
	snail.set_global_rotation(data["rotation"])
	Auto.game_time.set_raw_time(data["game_time"])
	#needs location setting
	#needs event flag setting
	#needs set entity locations
	Auto.play_time.set_raw_time(data["play_time"])

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

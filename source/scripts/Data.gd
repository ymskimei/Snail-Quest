extends Node

const config_path: String = "user://settings.cfg"
const data_path: String = "user://data/"

const data_file_type: String = ".sus" #super-ultra-save
const appearance_file_type: String = ".tres" #super-ultra-save
const encryption: String = "J051949" #january 5th, 1949

var current_data_folder: String = ""

var data_folder_0: String = data_path + "data 0/"
var data_folder_1: String = data_path + "data 1/"
var data_folder_2: String = data_path + "data 2/"
var data_folder_3: String = data_path + "data 3/"

var config = ConfigFile.new()

signal data_writing

func _ready() -> void:
	var dir: Directory = Directory.new()
	if !dir.dir_exists(data_path):
		dir.make_dir(data_path)

func _unhandled_input(event: InputEvent) -> void:
	if is_instance_valid(SnailQuest.controlled):
		if event.is_action_pressed(Device.debug_save):
			write_data(get_current_data_folder(), get_current_data())
		if event.is_action_pressed(Device.debug_load):
			load_data(get_data(get_current_data_folder()))
		if event.is_action_pressed(Device.screenshot):
			save_screenshot()

func set_config(section: String, key: String, value) -> void:
	config.set_value(section, key, value)
	config.save(config_path)

func get_config(section: String, key: String, value):
	config.load(config_path)
	return config.get_value(section, key, value)

func set_current_data_folder(data: String) -> void:
	current_data_folder = data

func get_current_data_folder() -> String:
	return current_data_folder

func get_data_folder(selection: int = 0) -> String:
	match selection:
		1:
			return data_folder_1
		2:
			return data_folder_2
		3:
			return data_folder_3
		_:
			return data_folder_0

func get_data(folder_path: String) -> Array:
	var data_file_path: String = folder_path + "save" + data_file_type
	var file: File = File.new()
	var data: Dictionary 
	var appearance: Resource = ResourceLoader.load(folder_path + "identity" + appearance_file_type)
	if file.file_exists(data_file_path):
		var open_file = file.open_encrypted_with_pass(data_file_path, File.READ, encryption)
		if open_file == OK:
			data = file.get_var()
			file.close()
	else:
		appearance = ResourceLoader.load("res://assets/resource/identity/snail/sheldon.tres")
		data = _get_new_data()
	return [data, appearance]

func get_SnailQuest_data(folder_path: String) -> Array:
	var all_SnailQuest_data: Array = Utility.get_files(folder_path + "SnailQuest/", true, true)
	return all_SnailQuest_data

func write_data(folder_path: String, data: Dictionary, SnailQuestmatic: bool = false) -> void:
	emit_signal("data_writing", true)
	var dir: Directory = Directory.new()
	if !dir.dir_exists(folder_path):
		dir.make_dir(folder_path)
	var data_file_path: String = folder_path + "save" + data_file_type
	var appearance_file_path: String = folder_path + "identity" + appearance_file_type
	if SnailQuestmatic:
		data_file_path = folder_path + "SnailQuest/" + _get_time_as_string() + data_file_type
		appearance_file_path = folder_path + "SnailQuest/" + _get_time_as_string() + appearance_file_type
	var file: File = File.new()
	var open_file = file.open_encrypted_with_pass(data_file_path, File.WRITE, encryption)
	if open_file == OK:
		file.store_var(data)
		file.close()
	ResourceSaver.save(appearance_file_path, SnailQuest.controlled.identity)
	emit_signal("data_writing", false)

func get_current_data() -> Dictionary:
	var snail: Spatial = SnailQuest.controlled
	var data: Dictionary = {
		"max_health":snail.get_max_health(),
		"health": snail.get_health(),
		"currency": snail.get_currency(),
		"keys": snail.get_keys(),
		"boss_key": snail.get_boss_key(),
		"items": snail.get_items(),
		"translation": snail.get_global_translation(),
		"rotation": snail.get_global_rotation(),
		"game_time": SnailQuest.game_time.get_raw_time(),
		"location": SnailQuest.get_world().get_rooms().get_child(0).filename,
		"event_flags": ["placeholder"],
		"nearby_entities": ["placeholder"],
		"play_time": SnailQuest.play_time.get_total_time(),
		"last_played": Time.get_date_string_from_system() + " " + Time.get_time_string_from_system(),
	}
	return data

func _get_new_data() -> Dictionary:
	var data: Dictionary = {
		"max_health": 3,
		"health": 3,
		"currency": 0,
		"keys": 0,
		"boss_key": 0,
		"items": [],
		"translation": Vector3.ZERO,
		"rotation": Vector3.ZERO,
		"game_time": 480,
		"location": "",
		"event_flags": [],
		"nearby_entities": [],
		"play_time": 0,
		"last_played": "Never",
	}
	return data

func load_data(data: Array) -> void:
	var snail = SnailQuest.controlled
	snail.identity = data[1]
	snail.max_health = data[0]["max_health"]
	snail.health = data[0]["health"]
	snail.currency = data[0]["currency"]
	snail.keys = data[0]["keys"]
	snail.boss_key = data[0]["boss_key"]
	snail.items = data[0]["items"]
	snail.set_global_translation(data[0]["translation"])
	snail.set_global_rotation(data[0]["rotation"])
	SnailQuest.camera.set_global_translation(data[0]["translation"])
	SnailQuest.camera.set_global_rotation(data[0]["rotation"])
	SnailQuest.game_time.set_raw_time(data[0]["game_time"])
	#needs location setting
	#needs event flag setting
	#needs set entity locations
	SnailQuest.play_time.reset_time_to(data[0]["play_time"])
	snail.update_appearance()

func save_screenshot() -> void:
	var extension: String = ".png"
	var dir = Directory.new()
	if current_data_folder != "":
		if !dir.dir_exists(current_data_folder + "screenshots/"):
			dir.make_dir(current_data_folder + "screenshots/")
		var image = get_screenshot()
		image.save_png(current_data_folder + "screenshots/" + _get_time_as_string() + extension)
	else:
		printerr("No current data folder to save images to! Use another screen capturer")

func get_screenshot() -> Image:
	var screen: Texture = get_viewport().get_texture()
	var image: Image = screen.get_data()
	image.flip_y()
	return image

func _get_time_as_string() -> String:
	var time: String =  Time.get_date_string_from_system() + "_" + Time.get_time_string_from_system().replace(":", ".")
	return time

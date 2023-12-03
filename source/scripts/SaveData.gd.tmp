extends Node

const SAVE_PATH = "user://save_data.json"
var game_data = {}

func _process(_delta):
	if Input.is_action_just_pressed("debug_save"):
		save_data()
	if Input.is_action_just_pressed("debug_load"):
		load_data()

func save_data():
	var file = File.new()
	file.open(SAVE_PATH, File.WRITE)
	game_data = {
		game_time = GlobalManager.game_time.get_raw_time(),
		play_time = GlobalManager.played_time.get_time()
	}
	file.store_line(to_json(game_data))
	file.close()

func load_data():
	var file = File.new()
	if !file.file_exists(SAVE_PATH):
		game_data = {
			game_time = "00:00",
			play_time = "00h, 00m, 00s"
		}
		save_data()
	file.open(SAVE_PATH, File.READ)
	var data = parse_json(file.get_line())
	GlobalManager.game_time.game_time = data.game_time
	GlobalManager.play_time.previous_time = data.play_time
	GlobalManager.play_time.played_time = 0
	GlobalManager.play_time.reset_start()
	file.close()

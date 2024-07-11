extends Node

var game_time: int = 0

func _ready() -> void:
	SnailQuest.set_game_time(self)
	var second_timer = Timer.new()
	second_timer.set_timer_process_mode(1)
	second_timer.set_wait_time(1)
	second_timer.connect("timeout", self, "on_unpaused_second")
	add_child(second_timer)
	second_timer.start()

func on_unpaused_second() -> void:
	game_time += 1 
	if (game_time >= (60 * 24)):
		game_time = 0

func set_raw_time(new_time: int) -> void:
	game_time = new_time

func get_raw_time() -> int:
	return game_time


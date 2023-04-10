extends Node

var game_master = preload("res://assets/world/game_master.tscn").instance()
var title_screen = preload("res://assets/gui/gui_screen_title.tscn").instance()

func _ready():
	add_child(title_screen)
	title_screen.connect("game_start", self, "on_Game_Started")

func on_Game_Started():
	print("demo")
	yield(title_screen, "tree_exited")
	add_child(game_master)

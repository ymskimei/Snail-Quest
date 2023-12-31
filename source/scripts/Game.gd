extends Node

var title_screen = preload("res://source/scenes/interface/screen_title.tscn").instance()

func _ready():
	add_child(title_screen)
	title_screen.connect("game_start", self, "on_Game_Started")

func on_Game_Started():
	yield(title_screen, "tree_exited")
	add_child(SnailQuest.starting_world)

extends Node

onready var display = $Control/MarginContainer/VBoxContainer/Label
onready var character = $Control/MarginContainer/VBoxContainer/Label

func _on_Button_button_down():
	display.text = character.get_dialog()

#func sentence_type_a() -> String:
#	var declaration: Array = ["Did you know that ", "It's amazing that ", "Would you believe that "]
#	var subject: Array = ["other snails ", "some flowers ", "all slugs ", "most clouds ", "so many rocks "]
#	var description: Array = ["are evil? ", "have no brain?? ", "think 100x faster upside-down? ", "don't like cheese?? ", "can't comprehend space-time? "]
#	var reason: Array = ["Seriously, it's true!!", "It surprised me too...", "You've got to believe me!!", "Izabell told me so!", "I just learned that today!!"]
#
#	var d1 = declaration[randi() % declaration.size()]
#	var s = subject[randi() % subject.size()]
#	var d2 = description[randi() % description.size()]
#	var c = reason[randi() % reason.size()]
#
#	var sentence: String = d1 + s + d2 + c
#
#	return sentence

extends Node

var test_response = "Placeholder"

func test_1(args: Array) -> String:
	#variables are 0=number
	return "EPICAMOUNT: " + args[0]

func set_controlled_name(new_name: String) -> void:
	SnailQuest.get_controlled().get_entity_identity().set_entity_name(new_name)

func get_controlled_name(_args: Array) -> String:
	return tr(SnailQuest.get_controlled().get_entity_identity().get_entity_name())

func set_test_response(new_word: String) -> void:
	test_response = new_word

func get_test_response(_args: Array) -> String:
	return test_response

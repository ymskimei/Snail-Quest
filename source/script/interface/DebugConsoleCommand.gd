class_name DebugConsoleCommand
extends Node

var call_back: String setget call_back_set, call_back_get

enum ArgumentType {
	INT,
	FLOAT,
	BOOL,
	STRING
}

export(Array, String) var argument_names = []
export(Array, ArgumentType) var argument_types = []

export var help: String = ""

func _ready():
	assert(argument_types.size() == argument_names.size())
	assert(name.find(" ") == -1)
	name = name.to_lower()

func call_back_set(string):
	call_back = "on_command_" + string

func call_back_get():
	return call_back

func parse_arguments(arguments: String):
	var argument_array = []
	var segmented = arguments.split(" ", false)
	var group: PoolStringArray = []
	var quote = false
	for segment in segmented:
		if segment.begins_with("\""):
			quote = true
			segment.erase (0, 1)
		if segment.ends_with("\""):
			quote = false
			segment.erase(segment.length() - 1, 1)
			group.push_back(segment)
			segment = group.join(" ")
			group = []
		if quote:
			group.push_back(segment)
		else:
			argument_array.push_back(segment)
	if group.size() != 0:
		return RegistryColor.get_bbcode(RegistryColor.red) + "Invalid argument format (Incomplete: %)" % group.join(" ") + "[/color]"
	if argument_array.size() != argument_types.size():
		return RegistryColor.get_bbcode(RegistryColor.red) + "Invalid amount of arguments (Required: %s, Recieved: %s)" % [String(argument_types.size()), String(argument_array.size())] + "[/color]"
	for i in range(argument_types.size()):
		match(argument_types[i]):
			ArgumentType.INT: argument_array[i] = int(argument_array[i])
			ArgumentType.FLOAT: argument_array[i] = float(argument_array[i])
			ArgumentType.BOOL: argument_array[i] = bool(argument_array[i])
	return argument_array

func get_usage():
	var command_usage = RegistryColor.get_bbcode(RegistryColor.red) + "Correct usage: [/color]%s" % name
	for i in range(argument_types.size()):
		var argument_type = ArgumentType.keys()[argument_types[i]]
		var argument_name = argument_names[i]
		argument_type = argument_type.to_lower()
		argument_name = argument_name.to_lower()
		command_usage += " <%s : %s>" % [argument_name, argument_type]
	return command_usage

func get_name_space_to(target: Node):
	var name_space : PoolStringArray = []
	var node = self
	while node != target:
		name_space.insert(0, node.name)
		node = node.get_parent()
	return name_space

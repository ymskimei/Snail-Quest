class_name GuiConsoleCategory
extends Node

export(NodePath) var command_handler_target = ".."
export var module_description: String = ""

var command_references : Dictionary
var command_handler = null
var command_console = null

func _ready():
	command_handler = get_node(command_handler_target)
	_build_command_dictionary(self)

func command_entered(command, arguments):
	var command_node = command_references[command]
	assert(command_node != null)
	var parse_result = command_node.parse_arguments(arguments)
	if parse_result is String:
		command_console.send_message(parse_result)
		command_console.send_message(command_node.get_usage())
		return
	if !command_handler.has_method(command_node.call_back):
		command_console.send_message("[color=#EA6A59]Command call back not found: /n" + command_node.call_back + "[/color]")
		return
	command_handler.call(command_node.call_back, command_console, parse_result)

func has_command(command: String):
	return command_references.has(command)

func _build_command_dictionary(target: Node):
	for child in target.get_children():
		if child is GuiConsoleCommand:
			var namespace = child.get_name_space_to(self)
			child.call_back = namespace.join("_")
			command_references[namespace.join(".")] = child
		else:
			_build_command_dictionary(child)

func generate_command_list():
	var message = "[color=#A8A8A8]Category:[/color] " + name
	message += " %s\n" % module_description
	for i in range(command_references.keys().size()):
		var command_string = command_references.keys()[i]
		var command_node = command_references.values()[i]
		message += "[color=#A8A8A8]•[/color] %s\n" % command_string
		message += "[color=#7F7F7F]   %s\n[/color]" % command_node.help
	return message

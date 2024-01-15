extends Node

onready var command_input = $"%CommandInput"
onready var command_display = $"%CommandDisplay"

export var message_buffer_limit = 100

var message_buffer : PoolStringArray = []
var command_modules : Array = []

func welcome_message():
	message_buffer = []
	command_display.bbcode_text = "[color=#7F7F7F]———[/color] [color=#A8A8A8]?[/color] Welcome [color=#A8A8A8]?[/color] [color=#7F7F7F]———[/color]\n"
	command_display.bbcode_text += "This is the Snowball Framework Command Console!\n"
	command_display.bbcode_text += "   You can use this interface to debug development features or use secret cheats.\n"
	command_display.bbcode_text += "   More information will be displayed here at a later date.\n"
	command_display.bbcode_text += "   Use the command 'help' for more.\n\n"
	
func add_command_module(module : GuiConsoleCategory):
	module.command_console = self
	command_modules.push_back(module)

func send_message(message):
	message_buffer.push_back(message)
	if message_buffer.size() > message_buffer_limit:
		message_buffer.remove(0)
	command_display.bbcode_text = message_buffer.join("\n")

func clear_console():
	message_buffer = []
	command_display.bbcode_text = ""

func parse_input(input):
	var token = input.split(" ", false, 1)
	if token.size() == 0:
		return
	var command = token[0].to_lower()
	var command_module = null
	for module in command_modules:
		if module.has_command(command):
			command_module = module
			break
	if command_module == null:
		send_message("[color=#EA6A59]Command could not be found: " + command + "[/color]")
		return
	var arguments = ""
	if token.size() > 1:
		arguments = token[1]
	command_module.command_entered(command, arguments)

func _on_CommandInput_text_entered(input):
	command_input.clear()
	if input.length() == 0:
		return
	parse_input(input)

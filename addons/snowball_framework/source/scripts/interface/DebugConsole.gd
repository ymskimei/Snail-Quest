extends Node

onready var text_input = $"%CommandInput"
onready var display = $"%CommandDisplay"

var buffer_limit = 128
var history_limit: int = 256
var history_index: int = -1

var history: Array = []
var buffer: PoolStringArray = []
var command_modules: Array = []

var error_color = RegistryColor.get_bbcode(RegistryColor.red)
var default_color = RegistryColor.get_bbcode(RegistryColor.white)
var light_color = RegistryColor.get_bbcode(RegistryColor.light_gray)
var dark_color = RegistryColor.get_bbcode(RegistryColor.dark_gray)
var success_color = RegistryColor.get_bbcode(RegistryColor.lime)

func _ready() -> void:
	_welcome_message()
	text_input.set_placeholder("Enter a command")
	
func _input(event: InputEvent):
	if !history.size() == 0:
		if event.is_action_pressed(Device.debug_menu_nav_up):
			_search_history(1)
		elif event.is_action_pressed(Device.debug_menu_nav_down):
			_search_history(-1)
	if event.is_action_pressed(Device.debug_menu_clear):
		text_input.text = ""

func _search_history(index: int) -> void:
	history_index = clamp(history_index + index, 0, history.size() - 1)
	text_input.text = history[history_index]
	text_input.caret_position = text_input.text.length()

func _welcome_message() -> void:
	var message = light_color + "——— ?[/color]" + default_color + " Welcome " + light_color + "? ———[/color]\n"
	message += "You can use this window for chat, or cheats, use the command '/help' for more."
	send_message(message)

func add_command_module(module: DebugConsoleCategory):
	module.command_console = self
	command_modules.push_back(module)

func send_message(message: String):
	buffer.push_back(message)
	if buffer.size() > buffer_limit:
		buffer.remove(0)
	display.bbcode_text = buffer.join("\n")

func clear_console():
	buffer = []
	display.bbcode_text = ""

func _parse_input(input: String):
	if input.begins_with("/"):
		var token = input.erase(0, 1)
		token = input.split(" ", false, 1)
		var command = token[0].to_lower()
		var command_module = null
		for module in command_modules:
			if module.has_command(command):
				command_module = module
				break
		if command_module == null:
			send_message(error_color + "Command not found: " + command + "[/color]")
			return
		var arguments = ""
		if token.size() > 1:
			arguments = token[1]
		send_message(light_color + "/" + input + "[/color]")
		command_module.command_entered(command, arguments)
	else:
		var n
		if SB.user_id != "":
			n = success_color + SB.user_id + ": [/color]"
		else:
			n = error_color + "Undefined: [/color]"
		send_message(n + input)

func _on_CommandInput_text_entered(input: String):
	if text_input.text.length() == 0:
		return
	else:
		history.push_front(input)
		_parse_input(input)
		if history.size() >= history_limit:
			history.remove(history_limit - 1)
		text_input.clear()

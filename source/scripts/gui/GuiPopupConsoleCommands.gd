extends Node

onready var command_console = get_node("../../../")

func _ready():
	command_console.add_command_module($Information)
	command_console.add_command_module($Utility)
	command_console.add_command_module($Fun)

func on_command_categories(_console, _args):
	var modules = command_console.command_modules
	var message = ""
	for module in modules:
		var commands = module.command_references.keys()
		for command in commands:
			message += "[color=#A8A8A8]%s[/color] [color=#7F7F7F]—>[/color] %s\n" % [module.name, command]
	command_console.send_message(message)

func on_command_clear(_console, _args):
	command_console.clear_console()

func on_command_debug(_console, _args):
	GuiMain.debug.show_debug_information()
	GuiMain.debug.close_command_console()

func on_command_help(_console, _args):
	var message = "[color=#7F7F7F]————[/color] [color=#A8A8A8]?[/color] Help [color=#A8A8A8]?[/color] [color=#7F7F7F]————[/color]\n"
	message += "How to use the command console:\n"
	message += "   Enter a command followed by it's arguments (separated with spaces!)\n"
	message += "   You can use quotation marks to ignore spaces within a command.\n\n"
	for module in command_console.command_modules:
		message += module.generate_command_list()
	command_console.send_message(message)

#Remove later
func on_command_aspect(_console, _args):
	var argument = _args[0].to_lower()
	var standard = "Aspect ratio changed to 4:3"
	var wide = "Aspect ratio changed to 16:9"
	if argument == "standard":
		ProjectSettings.set_setting("display/window/size/width", 1440)
		print(standard)
	elif argument == "4:3":
		ProjectSettings.set_setting("display/window/size/width", 1440)
		print(standard)
	elif argument == "widescreen":
		ProjectSettings.set_setting("display/window/size/width", 1920)
		print(wide)
	elif argument == "16:9":
		ProjectSettings.set_setting("display/window/size/width", 1920)
		print(wide)
	elif argument == "wide":
		ProjectSettings.set_setting("display/window/size/width", 1920)
		print(wide)

func on_command_cam(_console, args):
	if GlobalManager.controllable != null:
		GlobalManager.prev_controllable = GlobalManager.controllable
		GlobalManager.controllable = null
	else:
		GlobalManager.controllable = GlobalManager.prev_controllable
	GuiMain.debug.close_command_console()

func on_command_quit(_console, _args):
	get_tree().quit()

func on_command_restart(_console, _args):
	get_tree().reload_current_scene()
	GuiMain.debug.close_command_console()

func on_command_time(_console, args):
	GlobalManager.game_time.set_time(args[0])
	command_console.send_message("The world's time has been set to [color=#C3EF5D]%s[/color]\n" % args[0])

func on_command_say(_console, args):
	command_console.send_message(args[0])

func on_command_version(_console, _args):
	command_console.send_message("Snail Quest is on version [color=#C3EF5D]%s[/color]\n" % GlobalManager.version_number)

#immortal - enable/disable invincibility
#sethealth - add or remove health to an entity
#kill - set an entity's health to 0 instantly
#spawn - place an object at your currently position

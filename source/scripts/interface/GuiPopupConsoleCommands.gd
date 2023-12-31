extends Node

onready var command_console: Node = get_node("../../../")

func _ready() -> void:
	command_console.add_command_module($Information)
	command_console.add_command_module($Utility)
	command_console.add_command_module($Fun)

#Remove later
func on_command_aspect(_console, _args: Array) -> void:
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

func on_command_categories(_console, _args: Array) -> void:
	var modules = command_console.command_modules
	var message = ""
	for module in modules:
		var commands = module.command_references.keys()
		for command in commands:
			message += "[color=#A8A8A8]%s[/color] [color=#7F7F7F]—>[/color] %s\n" % [module.name, command]
	command_console.send_message(message)

func on_command_cam(_console, args: Array) -> void:
	if SnailQuest.controllable != null:
		SnailQuest.prev_controllable = SnailQuest.controllable
		SnailQuest.controllable = null
	else:
		SnailQuest.controllable = SnailQuest.prev_controllable
	#SnailQuest.interface.debug.command_console.close_command_console()

func on_command_clear(_console, _args: Array) -> void:
	command_console.clear_console()

func on_command_debug(_console, _args: Array) -> void:
	SnailQuest.interface.debug.show_debug_information()
	#command_console.close_command_console()

func on_command_help(_console, _args: Array) -> void:
	var message = "[color=#7F7F7F]————[/color] [color=#A8A8A8]?[/color] Help [color=#A8A8A8]?[/color] [color=#7F7F7F]————[/color]\n"
	message += "How to use the command console:\n"
	message += "   Enter a command followed by it's arguments (separated with spaces!)\n"
	message += "   You can use quotation marks to ignore spaces within a command.\n\n"
	for module in command_console.command_modules:
		message += module.generate_command_list()
	command_console.send_message(message)

func on_command_quit(_console, _args: Array) -> void:
	get_tree().quit()

func on_command_restart(_console, _args: Array) -> void:
	get_tree().reload_current_scene()
	#command_console.close_command_console()

func on_command_say(_console, args: Array) -> void:
	command_console.send_message(args[0])

#func on_command_spawn(_console, args: Array) -> void:
#	var object: String = args[0] + ".tres"
#	var all_entities: Array = MathHelper.get_file_paths(SnailQuest.entiies_folder, "tscn")
#	var all_objects: Array = MathHelper.get_file_paths(SnailQuest.entiies_folder, "tscn")
#	var all_items: Array = MathHelper.get_file_paths(SnailQuest.entiies_folder, "tscn")	
#	var found_world: String = ""

func on_command_time(_console, args: Array) -> void:
	SnailQuest.game_time.set_time(args[0])
	command_console.send_message("The world's time has been set to [color=#C3EF5D]%s[/color]\n" % args[0])

func on_command_tp(_console, args: Array) -> void:
	if is_instance_valid(SnailQuest.controllable):
		SnailQuest.controllable.set_coords(Vector3(args[0], args[1], args[2]))
	SnailQuest.camera.set_coords(Vector3(args[0], args[1], args[2]))

func on_command_version(_console, _args: Array) -> void:
	command_console.send_message("Snail Quest is on version [color=#C3EF5D]%s[/color]\n" % SnailQuest.version_number)

func on_command_warp(_console, args: Array) -> void:
	var directory = Directory.new();
	var warp_path: String = SnailQuest.warps + args[0] + ".tres"
	var all_worlds: Array = Utility.math.get_file_paths(SnailQuest.worlds, "tscn")
	var found_world: String = ""
	if is_instance_valid(SnailQuest.world):
		if all_worlds.size() > 0:
			for w in all_worlds:
				if w.ends_with(args[0] + ".tscn"):
					found_world = w
		if directory.file_exists(warp_path):
			var warp = load(warp_path)
			SnailQuest.world.load_room(load(warp.room_path), warp.coordinates, warp.direction)
		elif found_world != "":
			SnailQuest.world.load_room(load(found_world), Vector3.ZERO, "NORTH")
		else:
			var message = "[color=#A8A8A8]This warp's resource does not exist![/color]"
			command_console.send_message(message)

#immortal - enable/disable invincibility
#sethealth - add or remove health to an entity
#kill - set an entity's health to 0 instantly

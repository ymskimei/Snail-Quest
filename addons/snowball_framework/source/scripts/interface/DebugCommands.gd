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
	if SB.controlled == null:
		SB.controlled = SB.prev_controlled
	else:
		SB.prev_controlled = SB.controlled
		SB.controlled = null
	#SB.interface.debug.command_console.close_command_console()

func on_command_clear(_console, _args: Array) -> void:
	command_console.clear_console()

func on_command_debug(_console, _args: Array) -> void:
	SB.game.interface.debug.show_debug_information()
	command_console.close_command_console()

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
	SB.utility.pause(false)
	get_tree().reload_current_scene()
	#command_console.close_command_console()

func on_command_say(_console, args: Array) -> void:
	command_console.send_message(args[0])

#func on_command_spawn(_console, args: Array) -> void:
#	var object: String = args[0] + ".tres"
#	var all_entities: Array = MathHelper.get_file_paths(SB.entiies_folder, "tscn")
#	var all_objects: Array = MathHelper.get_file_paths(SB.entiies_folder, "tscn")
#	var all_items: Array = MathHelper.get_file_paths(SB.entiies_folder, "tscn")	
#	var found_world: String = ""

func on_command_time(_console, args: Array) -> void:
	SB.game_time.set_time(args[0])
	command_console.send_message("In-game time set to [color=#C3EF5D]%s[/color]\n" % args[0])

func on_command_tp(_console, args: Array) -> void:
	if is_instance_valid(SB.controlled):
		SB.controlled.set_coords(Vector3(args[0], args[1], args[2]))
	SB.camera.set_coords(Vector3(args[0], args[1], args[2]))

func on_command_version(_console, _args: Array) -> void:
	command_console.send_message("%s is on version [color=#C3EF5D]%s[/color]\n" % [SB.game.info["title"], SB.game.info["version"]])

func on_command_warp(_console, args: Array) -> void:
	if is_instance_valid(SB.world):
		var directory = Directory.new();
		var all_worlds: Array = SB.utility.get_files(SB.scene["world"], true)
		var warp_path: String = SB.resource["warp"] + args[0] + ".tres"
		if directory.file_exists(warp_path):
			var warp = load(warp_path)
			SB.world.load_room(load(warp.room_path), warp.coordinates, warp.direction)
		elif all_worlds.size() > 0:
			print(all_worlds)
			for w in all_worlds:
				if w.ends_with(args[0] + ".tscn"):
					SB.world.load_room(load(w), Vector3.ZERO, "NORTH")
		else:
			var message = "[color=#A8A8A8]This warp does not exist![/color]"
			command_console.send_message(message)

#immortal - enable/disable invincibility
#sethealth - add or remove health to an entity
#kill - set an entity's health to 0 instantly
#summon - bring an item, object, or entity into being

extends Node

onready var command_console: Node = get_node("../../../")

func _ready() -> void:
	command_console.add_command_module($Information)
	command_console.add_command_module($Utility)
	command_console.add_command_module($Fun)

func on_command_cam(_console, args: Array) -> void:
	if SB.controlled == null:
		SB.controlled = SB.prev_controlled
	else:
		SB.prev_controlled = SB.controlled
		SB.controlled = null
	SB.game.interface.get_menu(null, SB.game.interface.debug)

func on_command_clear(_console, _args: Array) -> void:
	command_console.clear_console()

func on_command_debug(_console, _args: Array) -> void:
	SB.game.interface.debug.show_debug_information()

func on_command_health(_console, args: Array) -> void:
	var message = command_console.error_color + "Nothing is controlled to have it's health changed![/color]"
	if SB.controlled and SB.controlled is Entity:
		SB.controlled.set_entity_health(args[0])
		message = "%s's health is now " % SB.controlled.entity_name + command_console.success_color + "%s[/color]" % SB.controlled.health
	command_console.send_message(message)

func on_command_help(_console, _args: Array) -> void:
	var message = command_console.light_color + "——— ?[/color]" + command_console.default_color + " Help " + command_console.light_color + "? ———[/color]\n"
	message += "Enter a command starting with '/', separate arguments with spaces. You can use quotation marks to ignore spaces in a command.\n"
	for module in command_console.command_modules:
		message += module.generate_command_list()
	command_console.send_message(message)
	
func on_command_immortal(_console, args: Array) -> void:
	var message = command_console.error_color + "Nothing is controlled to become immortal![/color]"
	if SB.controlled and SB.controlled is Entity:
		if SB.controlled.immortal:
			SB.controlled.immortal = false
			message = command_console.success_color + "%s is now mortal[/color]" % SB.controlled.entity_name
		else:
			SB.controlled.immortal = true
			message = command_console.success_color + "%s can never die[/color]" % SB.controlled.entity_name
	command_console.send_message(message)

func on_command_list(_console, _args: Array) -> void:
	var entities: PoolStringArray = SB.utility.get_names_from_paths(SB.scene["entity"])
	var objects: PoolStringArray = SB.utility.get_names_from_paths(SB.scene["object"])
	var items: PoolStringArray = SB.utility.get_names_from_paths(SB.scene["item"])
	var message = command_console.light_color + "——— ?[/color]" + command_console.default_color + " List " + command_console.light_color + "? ———[/color]\n"
	message += "When summoning and entity, item, or object, listed entries represent the available options to pick from\n"
	message += command_console.dark_color + "Entities:[/color]\n" + command_console.light_color + entities.join(", ") + "[/color]\n"
	message += command_console.dark_color + "Objects:[/color]\n" + command_console.light_color + objects.join(", ") + "[/color]\n"
	message += command_console.dark_color + "Items:[/color]\n" + command_console.light_color + items.join(", ") + "[/color]"
	command_console.send_message(message)

func on_command_lives(_console, args: Array) -> void:
	var message = command_console.error_color + "Nothing is controlled to have it's lives increased![/color]"
	if SB.controlled and SB.controlled is Entity:
		SB.controlled.set_entity_max_health(args[0])
		message = "%s's lives increased to " % SB.controlled.entity_name + command_console.success_color + "%s[/color]" % SB.controlled.max_health
	command_console.send_message(message)

func on_command_quit(_console, _args: Array) -> void:
	get_tree().quit()

func on_command_restart(_console, _args: Array) -> void:
	SB.utility.pause(false)
	get_tree().reload_current_scene()
	SB.game.interface.get_menu(null, SB.game.interface.debug)

func on_command_say(_console, args: Array) -> void:
	command_console.send_message(args[0])

func on_command_suicide(_console, args: Array) -> void:
	var message = command_console.error_color + "Nothing is controlled to be killed![/color]"
	if SB.controlled and SB.controlled is Entity:
		SB.controlled.kill_entity()
		message = command_console.error_color + "%s was killed[/color]" % SB.controlled.entity_name
	command_console.send_message(message)

func on_command_time(_console, args: Array) -> void:
	SB.game_time.set_time(args[0])
	command_console.send_message("World time set to " + command_console.success_color + "%s[/color]" % args[0])

func on_command_tp(_console, args: Array) -> void:
	var c = "Camera"
	if SB.controlled and SB.controlled is Entity:
		SB.controlled.set_coords(Vector3(args[0], args[1], args[2]))
		c = SB.controlled.entity_name
	SB.camera.set_coords(Vector3(args[0], args[1], args[2]))
	command_console.send_message("%s teleported to " % c + command_console.success_color + "%s, %s, %s[/color]" % [args[0], args[1], args[2]])

func on_command_version(_console, _args: Array) -> void:
	command_console.send_message("%s is on version " % SB.game.info["title"] + command_console.success_color + "%s[/color]" % SB.game.info["version"])

func on_command_warp(_console, args: Array) -> void:
	var message = command_console.error_color + "Nothing is controlled to allow warping![/color]"
	if SB.controlled and SB.controlled is Entity and SB.world:
		var directory = Directory.new();
		var all_worlds: Array = SB.utility.get_files(SB.scene["world"], true)
		var warp_path: String = SB.resource["warp"] + args[0] + ".tres"
		if directory.file_exists(warp_path):
			var warp = load(warp_path)
			SB.world.load_room(load(warp.room_path), warp.coordinates, warp.direction)
			message = "%s warped to " % SB.controlled.entity_name + command_console.success_color + "%s[/color]" % args[0]
		elif all_worlds.size() > 0:
			print(all_worlds)
			for w in all_worlds:
				if w.ends_with(args[0] + ".tscn"):
					SB.world.load_room(load(w), Vector3.ZERO, "NORTH")
			message = "%s warped to " % SB.controlled.entity_name + command_console.success_color + "%s[/color]" % args[0]
		else:
			message = command_console.error_color + "This warp does not exist![/color]"
	command_console.send_message(message)

func on_command_spawn(_console, args: Array) -> void:
	var path: String = SB.scene["entity"] + args[0] + ".tscn"
	var all: Array = SB.utility.get_files(SB.scene["entity"], true, true)
	if path in all:
		var room = SB.controlled.get_node("../").get_child(0).get_child(0)
		var new_pos: Vector3 = SB.camera.global_translation
		var new_rot: Vector3 = SB.camera.global_rotation
		for i in args[1]:
			var entity = load(path).instance()
			room.add_child(entity)
			if SB.controlled:
				new_pos = SB.controlled.global_translation
				new_rot = SB.controlled.global_rotation
			entity.global_translation = new_pos
			entity.global_rotation = Vector3(-new_rot.x, new_rot.y, -new_rot.z)

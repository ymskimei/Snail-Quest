extends Node

onready var command_console: Node = get_node("../../../")

func _ready() -> void:
	command_console.add_command_module($Information)
	command_console.add_command_module($Utility)
	command_console.add_command_module($Fun)

func on_command_cam(_console, args: Array) -> void:
	if SnailQuest.controlled == null:
		SnailQuest.controlled = SnailQuest.prev_controlled
	else:
		SnailQuest.prev_controlled = SnailQuest.controlled
		SnailQuest.controlled = null
	#SnailQuest.interface.get_menu(null, SnailQuest.interface.debug)

func on_command_clear(_console, _args: Array) -> void:
	command_console.clear_console()

func on_command_debug(_console, _args: Array) -> void:
	Interface.debug.show_debug_information()

func on_command_health(_console, args: Array) -> void:
	var message = command_console.error_color + "Nothing is controlled to have it's health changed![/color]"
	if SnailQuest.controlled and SnailQuest.controlled is Entity:
		SnailQuest.controlled.set_entity_health(args[0])
		message = "%s's health is now " % SnailQuest.controlled.entity_name + command_console.success_color + "%s[/color]" % SnailQuest.controlled.health
	command_console.send_message(message)

func on_command_help(_console, _args: Array) -> void:
	var message = command_console.light_color + "——— ?[/color]" + command_console.default_color + " Help " + command_console.light_color + "? ———[/color]\n"
	message += "Enter a command starting with '/', separate arguments with spaces. You can use quotation marks to ignore spaces in a command.\n"
	for module in command_console.command_modules:
		message += module.generate_command_list()
	command_console.send_message(message)
	
func on_command_immortal(_console, args: Array) -> void:
	var message = command_console.error_color + "Nothing is controlled to become immortal![/color]"
	if SnailQuest.controlled and SnailQuest.controlled is Entity:
		if SnailQuest.controlled.immortal:
			SnailQuest.controlled.immortal = false
			message = command_console.success_color + "%s is now mortal[/color]" % SnailQuest.controlled.entity_name
		else:
			SnailQuest.controlled.immortal = true
			message = command_console.success_color + "%s can never die[/color]" % SnailQuest.controlled.entity_name
	command_console.send_message(message)

func on_command_list(_console, _args: Array) -> void:
	var entities: PoolStringArray = Utility.get_names_from_paths(SnailQuest.scene["entity"], ".tscn")
	var objects: PoolStringArray = Utility.get_names_from_paths(SnailQuest.scene["object"], ".tscn")
	var items: PoolStringArray = Utility.get_names_from_paths(SnailQuest.scene["item"], ".tscn")
	var message = command_console.light_color + "——— ?[/color]" + command_console.default_color + " List " + command_console.light_color + "? ———[/color]\n"
	message += "When summoning and entity, item, or object, listed entries represent the available options to pick from\n"
	message += command_console.dark_color + "Entities:[/color]\n" + command_console.light_color + entities.join(", ") + "[/color]\n"
	message += command_console.dark_color + "Objects:[/color]\n" + command_console.light_color + objects.join(", ") + "[/color]\n"
	message += command_console.dark_color + "Items:[/color]\n" + command_console.light_color + items.join(", ") + "[/color]"
	command_console.send_message(message)

func on_command_lives(_console, args: Array) -> void:
	var message = command_console.error_color + "Nothing is controlled to have it's lives increased![/color]"
	if SnailQuest.controlled and SnailQuest.controlled is Entity:
		SnailQuest.controlled.set_entity_max_health(args[0])
		message = "%s's lives increased to " % SnailQuest.controlled.identity.get_entity_name() + command_console.success_color + "%s[/color]" % SnailQuest.controlled.max_health
	command_console.send_message(message)

func on_command_quit(_console, _args: Array) -> void:
	get_tree().quit()

func on_command_restart(_console, _args: Array) -> void:
	Utility.pause(false)
	get_tree().reload_current_scene()
	Interface.get_menu(null, Interface.debug)

func on_command_say(_console, args: Array) -> void:
	command_console.send_message(args[0])

func on_command_suicide(_console, args: Array) -> void:
	var message = command_console.error_color + "Nothing is controlled to be killed![/color]"
	if SnailQuest.controlled and SnailQuest.controlled is Entity:
		SnailQuest.controlled.kill_entity()
		message = command_console.error_color + "%s was killed[/color]" % SnailQuest.controlled.entity_name
	command_console.send_message(message)

func on_command_time(_console, args: Array) -> void:
	SnailQuest.game_time.set_raw_time(args[0])
	command_console.send_message("World time set to " + command_console.success_color + "%s[/color]" % args[0])

func on_command_tp(_console, args: Array) -> void:
	var c = "Camera"
	if SnailQuest.controlled and SnailQuest.controlled is Entity:
		SnailQuest.controlled.set_coords(Vector3(args[0], args[1], args[2]))
		c = SnailQuest.controlled.identity.get_entity_name()
	SnailQuest.camera.set_coords(Vector3(args[0], args[1], args[2]))
	command_console.send_message("%s teleported to " % c + command_console.success_color + "%s, %s, %s[/color]" % [args[0], args[1], args[2]])

func on_command_version(_console, _args: Array) -> void:
	command_console.send_message("%s is on version " % SnailQuest.info["title"] + command_console.success_color + "%s[/color]" % SnailQuest.info["version"])

func on_command_warp(_console, args: Array) -> void:
	var message = command_console.error_color + "Nothing is controlled to allow warping![/color]"
	if SnailQuest.controlled and SnailQuest.controlled is Entity and SnailQuest.world:
		var directory = Directory.new();
		var all_worlds: Array = Utility.get_files(SnailQuest.scene["world"], true)
		var warp_path: String = SnailQuest.resource["warp"] + args[0] + ".tres"
		if directory.file_exists(warp_path):
			var warp = load(warp_path)
			SnailQuest.world.load_room(load(warp.room_path), warp.coordinates, warp.direction)
			message = "%s warped to " % SnailQuest.controlled.identity.get_entity_name() + command_console.success_color + "%s[/color]" % args[0]
		elif all_worlds.size() > 0:
			print(all_worlds)
			for w in all_worlds:
				if w.ends_with(args[0] + ".tscn"):
					SnailQuest.world.load_room(load(w), Vector3.ZERO, "NORTH")
			message = "%s warped to " % SnailQuest.controlled.identity.get_entity_name() + command_console.success_color + "%s[/color]" % args[0]
		else:
			message = command_console.error_color + "This warp does not exist![/color]"
	command_console.send_message(message)

func on_command_spawn(_console, args: Array) -> void:
	var message = command_console.error_color + "No entity was found with that name![/color]"
	var path: String = SnailQuest.scene["entity"] + args[0] + ".tscn"
	var all: Array = Utility.get_files(SnailQuest.scene["entity"], true, true)
	if path in all:
		var room = SnailQuest.get_controlled().get_node("../").get_child(0).get_child(0)
		var new_pos: Vector3 = SnailQuest.get_camera().get_global_translation()
		var new_rot: Vector3 = SnailQuest.get_camera().get_global_rotation()
		for i in args[1]:
			var entity = load(path).instance()
			entity.set_physics_process(false)
			entity.set_visible(false)
			room.add_child(entity)
			if SnailQuest.get_controlled():
				new_pos = SnailQuest.get_controlled().get_global_translation()
				new_rot = SnailQuest.get_controlled().get_global_rotation()
			entity.set_global_translation(new_pos + Vector3(Utility.rng.randf_range(-1.5, 1.5), 10, Utility.rng.randf_range(-1.5, 1.5)))
			entity.set_global_rotation(Vector3(-new_rot.x, new_rot.y, -new_rot.z))
		var entity_name = args[0]
		var plural = "s"
		if args[0].ends_with("s") or args[0].ends_with("i"):
			plural = ""
		elif args[0].ends_with("y"):
			entity_name.erase(entity_name.length() - 1, 1)
			plural = "ies"
		message = "%s spawned " % SnailQuest.get_controlled().get_entity_identity().get_entity_name() + command_console.success_color + "%s %s" % [args[1], entity_name] + plural + "[/color]"
	command_console.send_message(message)

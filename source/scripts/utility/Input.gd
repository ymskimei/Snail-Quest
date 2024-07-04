extends Node

var deadzone: float = 0.25

var device: String = DEVICE_CONTROLLER_GENERIC
var device_index: int = -1
var device_last_changed_at: int = 0

const DEVICE_KEYBOARD: String = "keyboard"
const DEVICE_CONTROLLER_TYPE_1: String = "n"
const DEVICE_CONTROLLER_TYPE_2: String = "p"
const DEVICE_CONTROLLER_TYPE_3: String = "x"
const DEVICE_CONTROLLER_GENERIC: String = "generic"

const stick_main_left: String = "joy_left"
const stick_main_right: String = "joy_right"
const stick_main_up: String = "joy_up"
const stick_main_down: String = "joy_down"
const action_main: String = "action_main"
const action_alt: String = "action_alt"
const action_sub_0: String = "action_sub_0"
const action_sub_1: String = "action_sub_1"
const pad_left: String = "pad_left"
const pad_right: String = "pad_right"
const pad_up: String = "pad_up"
const pad_down: String = "pad_down"
const stick_alt_left: String = "cam_left"
const stick_alt_right: String = "cam_right"
const stick_alt_up: String = "cam_up"
const stick_alt_down: String = "cam_down"
const trigger_right: String = "action_defense"
const trigger_left: String = "cam_lock"
const button_right: String = "cam_zoom"
const button_left: String = ""
const stick_main: String = ""
const stick_alt: String = ""
const main_0: String = "gui_pause"
const main_1: String = "gui_items"
const screenshot: String = "screenshot"
const debug_menu: String = "debug_menu"
const debug_menu_nav_up: String = "debug_menu_nav_up"
const debug_menu_nav_down: String = "debug_menu_nav_down"
const debug_menu_clear: String = "debug_menu_clear"
const debug_save: String = "debug_save"
const debug_load: String = "debug_load"
const debug_cam_higher: String = "debug_cam_higher"
const debug_cam_lower: String = "debug_cam_lower"
const debug_speed_up: String = "debug_cam_speed_up"
const debug_speed_down: String = "debug_cam_speed_down"
const debug_fov_increase: String = "debug_cam_fov_increase"
const debug_fov_decrease: String = "debug_cam_fov_decrease"

signal device_changed(device, device_index)
signal action_key_changed(action_name, key)
signal action_button_changed(action_name, button)

func _input(event: InputEvent) -> void:
	var next_device: String = device
	var next_device_index: int = device_index
	if event is InputEventKey and event.is_pressed():
		next_device = DEVICE_KEYBOARD
		next_device_index = -1
	elif (event is InputEventJoypadButton and event.is_pressed()) \
		or (event is InputEventJoypadMotion and event.axis_value > deadzone):
		next_device = get_simplified_device_name(Input.get_joy_name(event.device))
		next_device_index = event.device
	var not_changed_just_then = Engine.get_idle_frames() - device_last_changed_at > Engine.get_frames_per_second()
	if next_device != device or (next_device_index != device_index and not_changed_just_then):
		device_last_changed_at = Engine.get_idle_frames()
		device = next_device
		device_index = next_device_index
		emit_signal("device_changed", device, device_index)
		#_get_all_devices()

func get_simplified_device_name(raw_name: String) -> String:
	match raw_name:
		"n":
			return DEVICE_CONTROLLER_TYPE_1
		"p":
			return DEVICE_CONTROLLER_TYPE_2
		"x":
			return DEVICE_CONTROLLER_TYPE_3
		_:
			return DEVICE_CONTROLLER_GENERIC

func has_gamepad() -> bool:
	return Input.get_connected_joypads().size() > 0

func guess_device_name(i: int = 0) -> String:
	var connected_joypads = Input.get_connected_joypads()
	if connected_joypads.size() == 0:
		return DEVICE_KEYBOARD
	else:
		return get_simplified_device_name(Input.get_joy_name(i))

func reset_all_actions() -> void:
	InputMap.load_from_globals()
	for action in InputMap.get_actions():
		emit_signal("action_button_changed", action, get_action_button(action))
		emit_signal("action_key_changed", action, get_action_key(action))

func is_valid_key(key: String) -> bool:
	if key.length() == 1: return true
	if key in [
			"Up", "Down", "Left", "Right", 
			"Space", "Enter", 
			"Comma", "Period", 
			"Slash", "BackSlash", 
			"Minus", "Equal", 
			"Semicolon", "Apostrophe",
			"BracketLeft", "BracketRight"
		]: return true
	return false

func get_action_key(action: String) -> String:
	for event in InputMap.get_action_list(action):
		if event is InputEventKey:
			var scancode = OS.keyboard_get_scancode_from_physical(event.physical_scancode) if event.physical_scancode != 0 else event.scancode
			return OS.get_scancode_string(scancode)
	return ""

func set_action_key(target_action: String, key: String, swap_if_taken: bool = true) -> int:
	if not is_valid_key(key): return ERR_INVALID_DATA
	var clashing_action = ""
	var clashing_event
	if swap_if_taken:
		for action in InputMap.get_actions():
			for event in InputMap.get_action_list(action):
				if event is InputEventKey and event.as_text() == key:
					clashing_action = action
					clashing_event = event
	for event in InputMap.get_action_list(target_action):
		if event is InputEventKey:
			if clashing_action:
				InputMap.action_erase_event(clashing_action, clashing_event)
				InputMap.action_add_event(clashing_action, event)
				emit_signal("action_key_changed", clashing_action, event.as_text())
			InputMap.action_erase_event(target_action, event)
	var next_event = InputEventKey.new()
	next_event.scancode = OS.find_scancode_from_string(key)
	InputMap.action_add_event(target_action, next_event)
	emit_signal("action_key_changed", target_action, next_event.as_text())
	return OK

func get_action_button(action: String) -> int:
	for event in InputMap.get_action_list(action):
		if event is InputEventJoypadButton:
			return event.button_index
	return -1

func set_action_button(target_action: String, button: int, swap_if_taken: bool = true) -> int:
	var clashing_action = ""
	var clashing_event
	if swap_if_taken:
		for action in InputMap.get_actions():
			for event in InputMap.get_action_list(action):
				if event is InputEventJoypadButton and event.button_index == button:
					clashing_action = action
					clashing_event = event
	for event in InputMap.get_action_list(target_action):
		if event is InputEventJoypadButton:
			if clashing_action:
				InputMap.action_erase_event(clashing_action, clashing_event)
				InputMap.action_add_event(clashing_action, event)
				emit_signal("action_button_changed", clashing_action, event.button_index)
			InputMap.action_erase_event(target_action, event)
	var next_event = InputEventJoypadButton.new()
	next_event.button_index = button
	InputMap.action_add_event(target_action, next_event)
	emit_signal("action_button_changed", target_action, next_event.button_index)
	return OK

func rumble_small(target_device: int = 0) -> void:
	Input.start_joy_vibration(target_device, 0.4, 0, 0.1)

func rumble_medium(target_device: int = 0) -> void:
	Input.start_joy_vibration(target_device, 0, 0.7, 0.1)

func rumble_large(target_device: int = 0) -> void:
	Input.start_joy_vibration(target_device, 0, 1, 0.1)

func start_rumble_small(target_device: int = 0) -> void:
	Input.start_joy_vibration(target_device, 0.4, 0, 0)

func start_rumble_medium(target_device: int = 0) -> void:
	Input.start_joy_vibration(target_device, 0, 0.7, 0)

func start_rumble_large(target_device: int = 0) -> void:
	Input.start_joy_vibration(target_device, 0, 1, 0)

func stop_rumble(target_device: int = 0) -> void:
	Input.stop_joy_vibration(target_device)

func _get_all_devices() -> void:
	print("Device 0: " + guess_device_name(0) + "\nDevice 1: " + guess_device_name(1) + "\nDevice 2: " + guess_device_name(2) + "\nDevice 3: " + guess_device_name(3))

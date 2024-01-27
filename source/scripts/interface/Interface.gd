extends InterfaceParent

onready var debug: Menu = $Debug

onready var blur: AnimationPlayer = $Blur/AnimationPlayer

onready var cursor: CanvasLayer = $Cursor
onready var hud: CanvasLayer = $HUD
onready var options: Menu = $Options
onready var inventory: Menu = $Inventory

func _process(_delta: float):
	if !SB.controlled or get_tree().paused == true:
		hud.hide() 
		cursor.show()
	elif SB.controlled is Entity or VehicleBody:
		hud.show()
		cursor.hide()

func _unhandled_input(event: InputEvent):
	if debug.visible:
		if event.is_action_pressed(Device.debug_menu):
			get_menu()
	else:
		if event.is_action_pressed(Device.debug_menu):
			get_menu(null, debug)
		if SB.controlled:
			if event.is_action_pressed(Device.main_0):
				get_menu(blur, options)
			if event.is_action_pressed(Device.main_1):
				get_menu(blur, inventory)
		if event.is_action_pressed(Device.action_alt):
			get_menu(blur)

extends InterfaceParent

onready var debug: Menu = $Debug

onready var blur: AnimationPlayer = $Blur/AnimationPlayer
onready var transition: AnimationPlayer =  $Transition/AnimationPlayer

onready var cursor: CanvasLayer = $Cursor
onready var hud: CanvasLayer = $HUD
onready var options: Menu = $Options
onready var inventory: Menu = $Inventory

onready var indicator: TextureRect = $Indicator/MarginContainer/TextureRect

func _ready() -> void:
	_on_data_writing(false)
	Data.connect("data_writing", self, "_on_data_writing")

func _process(_delta: float):
	if !Device.get_block_input():
		if !SnailQuest.controlled or get_tree().paused == true:
			hud.hide() 
			cursor.show()
		elif SnailQuest.controlled is Entity or VehicleBody:
			hud.show()
			cursor.hide()

func _unhandled_input(event: InputEvent):
	if debug.visible:
		if event.is_action_pressed(Device.debug_menu):
			get_menu()
	else:
		if event.is_action_pressed(Device.debug_menu):
			get_menu(null, debug)
		if SnailQuest.controlled:
			if event.is_action_pressed(Device.main_0):
				get_menu(blur, options)
			if event.is_action_pressed(Device.main_1):
				get_menu(blur, inventory)
		if event.is_action_pressed(Device.action_alt):
			get_menu(blur)

func _on_data_writing(active) -> void:
	if active:
		indicator.texture.pause = false
		indicator.set_visible(true)
	else:
		indicator.texture.pause = true
		indicator.set_visible(false)

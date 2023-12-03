extends CanvasLayer

export(Resource) var equipment
export(Resource) var tools

onready var anim_pad = $AnimationPad
onready var anim_cam = $AnimationCam

onready var tool_slot = $"%ToolSlot"
onready var item_slot_1 = $"%ItemSlot1"
onready var item_slot_2 = $"%ItemSlot2"

onready var display_left = $"%ToolDisplayLeft"
onready var display_down = $"%ToolDisplayBottom"
onready var display_right = $"%ToolDisplayRight"
onready var display_up = $"%ToolDisplayTop"

onready var cam_icon = $"%CamIcon"

var cam_iso = preload("res://assets/texture/gui/gui_hud_cam_iso.png")
var cam_look = preload("res://assets/texture/gui/gui_hud_cam_look.png")
var cam_pan = preload("res://assets/texture/gui/gui_hud_cam_pan.png")
var cam_no_target = preload("res://assets/texture/gui/gui_hud_cam_no_target.png")
var cam_target = preload("res://assets/texture/gui/gui_hud_cam_target.png")
var cam_zoom = preload("res://assets/texture/gui/gui_hud_cam_zoom.png")

var pad_timer = Timer.new()
var cam_timer = Timer.new()

var pad_is_hidden : bool
var cam_is_hidden : bool

func _ready():
	pad_is_hidden = true
	cam_is_hidden = true
	add_hud_timers()
	equipment.connect("items_updated", self, "on_items_updated")
	tools.connect("items_updated", self, "on_items_updated")

func _process(_delta):
	update_cam_display()
	update_inventory_display()
	if !equipment.items[0] == tools.items[0]:
		display_right.is_deselected_animation()
	if !equipment.items[0] == tools.items[1]:
		display_down.is_deselected_animation()
	if !equipment.items[0] == tools.items[2]:
		display_left.is_deselected_animation()
	if !equipment.items[0] == tools.items[3]:
		display_up.is_deselected_animation()

func _unhandled_input(_event):
	if Input.is_action_just_pressed("pad_right"):
		display_right.destination.set_item(0, display_right.contained_item)
		display_right.is_selected_animation()
	if Input.is_action_just_pressed("pad_down"):
		display_down.destination.set_item(0, display_down.contained_item)
		display_down.is_selected_animation()
	if Input.is_action_just_pressed("pad_left"):
		display_left.destination.set_item(0, display_left.contained_item)
		display_left.is_selected_animation()
	if Input.is_action_just_pressed("pad_up"):
		display_up.destination.set_item(0, display_up.contained_item)
		display_up.is_selected_animation()
	if Input.is_action_just_pressed("pad_right") or Input.is_action_just_pressed("pad_down") or Input.is_action_just_pressed("pad_left") or Input.is_action_just_pressed("pad_up"):
		reveal_pad()
		#GlobalManager.player.update_equipped_tool()
	if Input.is_action_just_pressed("cam_zoom") or Input.is_action_just_pressed("cam_lock"):
		reveal_cam()

func update_item_slot_display():
	tool_slot.item_display(equipment.items[0])
	item_slot_1.item_display(equipment.items[1])
	item_slot_2.item_display(equipment.items[2])
	display_right.item_display(tools.items[0])
	display_down.item_display(tools.items[1])
	display_left.item_display(tools.items[2])
	display_up.item_display(tools.items[3])

func update_inventory_display():
	for item_index in equipment.items.size():
		update_item_slot_display()

func on_items_updated(index):
	reveal_pad()
	for item_index in index:
		update_item_slot_display()

func update_cam_display():
	if is_instance_valid(GlobalManager.camera):
		var state = str(GlobalManager.camera.states.current_state.get_name())
		match state:
			"Orbi": 
				var zoom_mode = GlobalManager.camera.states.current_state.zoom_mode
				if zoom_mode:
					cam_icon.texture = cam_zoom
				else:
					cam_icon.texture = cam_pan
			"Targ":
				var bars_active = GlobalManager.camera.states.current_state.bars_active
				if bars_active:
					if is_instance_valid(GlobalManager.player):
						var target_found = GlobalManager.player.target_found
						if target_found:
							cam_icon.texture = cam_target
						else:
							cam_icon.texture = cam_no_target
			"Isom":
				cam_icon.texture = cam_iso
			"Look":
				cam_icon.texture = cam_look

func add_hud_timers():
	pad_timer.set_wait_time(8)
	pad_timer.one_shot = true
	pad_timer.connect("timeout", self, "on_pad_timeout")
	add_child(pad_timer)
	cam_timer.set_wait_time(8)
	cam_timer.one_shot = true
	cam_timer.connect("timeout", self, "on_cam_timeout")
	add_child(cam_timer)

func reveal_pad():
	if pad_is_hidden:
		pad_is_hidden = false
		anim_pad.play("SlidePad")
	pad_timer.start()

func reveal_cam():
	if cam_is_hidden:
		cam_is_hidden = false
		anim_cam.play("SlideCam")
	cam_timer.start()

func on_pad_timeout():
	pad_is_hidden = true
	anim_pad.play_backwards("SlidePad")

func on_cam_timeout():
	cam_is_hidden = true
	anim_cam.play_backwards("SlideCam")

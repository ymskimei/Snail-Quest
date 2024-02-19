extends CanvasLayer

export(Resource) var equipment
export(Resource) var tools

onready var anim_cam: AnimationPlayer = $AnimationCam
onready var display_boost: RichTextLabel  = $DisplayBoost
onready var interaction_label: RichTextLabel = $InteractionLabel

onready var shell_stock: VBoxContainer = $MarginContainer/HBoxContainer/MarginContainer/ShellStock
onready var shell: TextureRect = $MarginContainer/HBoxContainer/TextureRect/Shell
onready var slime: TextureRect = $MarginContainer/HBoxContainer/TextureRect/Slime
onready var shell_anim: AnimationPlayer = $MarginContainer/HBoxContainer/TextureRect/AnimationPlayer

#move this later
onready var cursor_target: Spatial = $CursorTarget

onready var tool_slot = $"%ToolSlot"

onready var item_slot_1 = $"%ItemSlot1"
onready var item_slot_2 = $"%ItemSlot2"
onready var item_slot_3 = $"%ItemSlot3"
onready var item_slot_4 = $"%ItemSlot4"

onready var cam_icon = $"%CamIcon"

var shell_stock_icons: Array = []

var cam_iso = preload("res://assets/texture/interface/hud/camera_isometric.png")
var cam_look = preload("res://assets/texture/interface/hud/camera_look.png")
var cam_pan = preload("res://assets/texture/interface/hud/camera_pan.png")
var cam_no_target = preload("res://assets/texture/interface/hud/camera_target_found.png")
var cam_target = preload("res://assets/texture/interface/hud/camera_target_none.png")
var cam_zoom = preload("res://assets/texture/interface/hud/camera_zoom.png")

var shell_1 = preload("res://assets/texture/interface/hud/shell_1.png")
var shell_2 = preload("res://assets/texture/interface/hud/shell_2.png")
var shell_3 = preload("res://assets/texture/interface/hud/shell_3.png")
var shell_stock_full = preload("res://assets/texture/interface/hud/shell_stock_full.png")
var shell_stock_empty = preload("res://assets/texture/interface/hud/shell_stock_empty.png")

var pad_timer = Timer.new()
var cam_timer = Timer.new()

var pad_is_hidden: bool
var cam_is_hidden: bool

var target_cursor_exists: bool

func _ready() -> void:
	pad_is_hidden = true
	cam_is_hidden = true
	add_hud_timers()
	Item.connect("items_updated", self, "on_items_updated")
	SB.connect("controlled_health_change", self, "_on_controlled_health_changed")
	shell_stock_icons = get_tree().get_nodes_in_group("stock")

func _process(_delta: float) -> void:
	update_cam_display()
	update_inventory_display()
#	if !equipment.items[0] == tools.items[0]:
#		display_right.is_deselected_animation()
#	if !equipment.items[0] == tools.items[1]:
#		display_down.is_deselected_animation()
#	if !equipment.items[0] == tools.items[2]:
#		display_left.is_deselected_animation()
#	if !equipment.items[0] == tools.items[3]:
#		display_up.is_deselected_animation()
	display_vehicle_boost()

func _physics_process(delta: float) -> void:
	if is_instance_valid(SB.controlled) and SB.controlled.all_targets.size() > 0:
		cursor_target.show()
	else:
		cursor_target.hide()

func _unhandled_input(event: InputEvent) -> void:
#	if Input.is_action_just_pressed("action_combat"):
#		Utility.item.set_item(display_up.destination.items, 0, display_up.contained_item)
#		SnailQuest.controllable.update_equipped()
	if event.is_action_pressed("cam_zoom") or event.is_action_pressed("cam_lock"):
		reveal_cam()

func _on_controlled_health_changed(health, max_health, b) -> void:
	var fract = 3
	if health % fract == 0 and health != 0:
		shell_anim.play("Disappear")
		if shell_anim.is_playing():
			yield(shell_anim, "animation_finished")
			shell_anim.play("Appear")
		shell.texture = shell_3
	elif health % fract == 2:
		shell.texture = shell_2
	elif health % fract == 1:
		shell.texture = shell_1
	else:
		shell_anim.play("Disappear")
		yield(shell_anim, "animation_finished")
		shell.texture = null
	for i in range(shell_stock_icons.size()):
		if (i * fract) >= max_health - (fract + 1):
			shell_stock_icons[i].hide()
		else:
			shell_stock_icons[i].show()
		if (i * fract) <= health - (fract + 1):
			shell_stock_icons[i].texture = shell_stock_full
		else:
			shell_stock_icons[i].texture = shell_stock_empty

func update_item_slot_display() -> void:
	tool_slot.item_display(equipment.items[0])
	item_slot_1.item_display(equipment.items[1])
	item_slot_2.item_display(equipment.items[2])
	item_slot_3.item_display(equipment.items[3])
	item_slot_4.item_display(equipment.items[4])

func update_inventory_display() -> void:
	for item_index in equipment.items.size():
		update_item_slot_display()

func on_items_updated(index) -> void:
	for item_index in index:
		update_item_slot_display()

func update_cam_display() -> void:
	if is_instance_valid(SB.camera):
		var state = str(SB.camera.states.current_state.get_name())
		match state:
			"Orbi": 
				var zoom_mode = SB.camera.states.current_state.zoom_mode
				if zoom_mode:
					cam_icon.texture = cam_zoom
				else:
					cam_icon.texture = cam_pan
			"Targ":
				var bars_active = SB.camera.states.current_state.bars_active
				if bars_active:
					if is_instance_valid(SB.controlled):
						var target_found = SB.controlled.target_found
						if target_found:
							cam_icon.texture = cam_target
						else:
							cam_icon.texture = cam_no_target
			"Isom":
				cam_icon.texture = cam_iso
			"Look":
				cam_icon.texture = cam_look

func add_hud_timers() -> void:
	pad_timer.set_wait_time(8)
	pad_timer.one_shot = true
	pad_timer.connect("timeout", self, "on_pad_timeout")
	add_child(pad_timer)
	cam_timer.set_wait_time(8)
	cam_timer.one_shot = true
	cam_timer.connect("timeout", self, "on_cam_timeout")
	add_child(cam_timer)

func reveal_cam() -> void:
	if cam_is_hidden:
		cam_is_hidden = false
		anim_cam.play("SlideCam")
	cam_timer.start()

func on_cam_timeout() -> void:
	cam_is_hidden = true
	anim_cam.play_backwards("SlideCam")

func display_vehicle_boost() -> void:
	if is_instance_valid(SB.controlled):
		if SB.controlled is VehicleBody:
			var remaining = SB.controlled.boost_remaining
			display_boost.set_bbcode("[color=#C3EF5D]%s" % remaining)
		else:
			display_boost.set_bbcode("")

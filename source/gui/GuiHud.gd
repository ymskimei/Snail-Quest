extends CanvasLayer

export(Resource) var equipment
export(Resource) var tools

onready var anim = $AnimationPlayer

onready var tool_slot = $"%ToolSlot"
onready var item_slot_1 = $"%ItemSlot1"
onready var item_slot_2 = $"%ItemSlot2"

onready var display_left = $"%ToolDisplayLeft"
onready var display_down = $"%ToolDisplayBottom"
onready var display_right = $"%ToolDisplayRight"
onready var display_up = $"%ToolDisplayTop"

var timer
var pad_is_hidden : bool

func _ready():
	pad_is_hidden = true
	timer = Timer.new()
	timer.set_wait_time(5)
	timer.one_shot = true
	timer.connect("timeout", self, "on_timeout")
	add_child(timer)
	equipment.connect("items_updated", self, "on_items_updated")
	tools.connect("items_updated", self, "on_items_updated")

func _process(_delta):
	update_inventory_display()
	if !equipment.items[0] == tools.items[0]:
		display_right.is_deselected_animation()
	if !equipment.items[0] == tools.items[1]:
		display_down.is_deselected_animation()
	if !equipment.items[0] == tools.items[2]:
		display_left.is_deselected_animation()
	if !equipment.items[0] == tools.items[3]:
		display_up.is_deselected_animation()

func _unhandled_input(event):
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
		GlobalManager.player.update_equipped_tool()
		timer.start()

func update_item_slot_display(item_index):
	tool_slot.item_display(equipment.items[0])
	item_slot_1.item_display(equipment.items[1])
	item_slot_2.item_display(equipment.items[2])
	display_right.item_display(tools.items[0])
	display_down.item_display(tools.items[1])
	display_left.item_display(tools.items[2])
	display_up.item_display(tools.items[3])

func update_inventory_display():
	for item_index in equipment.items.size():
		update_item_slot_display(item_index)

func on_items_updated(index):
	reveal_pad()
	for item_index in index:
		update_item_slot_display(item_index)

func reveal_pad():
	if pad_is_hidden:
		pad_is_hidden = false
		anim.play("Slide")

func on_timeout():
	pad_is_hidden = true
	anim.play_backwards("Slide")

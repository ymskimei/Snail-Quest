extends CanvasLayer

var inventory = preload ("res://resource/tools.tres")
var tools_open : bool

func _ready():
	inventory.connect("items_updated", self, "on_items_updated")
	update_inventory_display()

func _process(delta):
	if Input.is_action_just_pressed("gui_tools"):
		get_tree().set_deferred("paused", true)
		$AnimationPlayer.play("Open")
		tools_open = true
		$ColorRect/CenterContainer/CircularContainer/CenterContainer.button.grab_focus()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	elif Input.is_action_just_released("gui_tools"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		get_tree().set_deferred("paused", false)
		tools_open = false
		$AnimationPlayer.play("Exit")

func update_inventory_display():
	for item_index in inventory.items.size():
		update_item_slot_display(item_index)

func update_item_slot_display(item_index):
	var inventory_slot_display = $"%CircularContainer".get_child(item_index)
	var item = inventory.items[item_index]
	inventory_slot_display.item_display(item)

func on_items_updated(index):
	for item_index in index:
		update_item_slot_display(item_index)

extends CanvasLayer

var tools = preload ("res://resource/tools.tres")
var tools_open : bool

func _ready():
	tools.connect("items_updated", self, "on_items_updated")
	tools.duplicate_item_instances()

func _process(delta):
	if Input.is_action_just_pressed("gui_tools"):
		update_inventory_display()
		$AnimationPlayer.play("Open")
		get_tree().set_deferred("paused", true)
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		tools_open = true
		$"%CenterContainer".button.grab_focus()
	elif Input.is_action_just_released("gui_tools"):
		$AnimationPlayer.play("Exit")
		get_tree().set_deferred("paused", false)
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		tools_open = false

func update_item_slot_display(item_index):
	var inventory_slot_display = $"%CircularContainer".get_child(item_index)
	var item = tools.items[item_index]
	inventory_slot_display.item_display(item)

func update_inventory_display():
	for item_index in tools.items.size():
		update_item_slot_display(item_index)

func on_items_updated(index):
	for item_index in index:
		update_item_slot_display(item_index)
	print(tools.items)

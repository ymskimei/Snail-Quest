extends CanvasLayer

onready var container = $"%CircularContainer"
var tools = preload ("res://resource/gui_tools.tres")
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
		for child in container.get_children():
			if child.is_in_group("tool_button"):
				if child.get_node("Button").has_focus():
					child.equipment.set_item(0, child.contained_item)
					print(child.equipment.items)
		$AnimationPlayer.play("Exit")
		get_tree().set_deferred("paused", false)
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		tools_open = false
	if tools_open:
		if Input.is_action_just_pressed("ui_right"):
			#container.set_start_angle_deg(lerp(container.get_start_angle_deg(), stepify(container.get_start_angle_deg() + -30, 30), 10 * delta))
			print(container.get_start_angle_deg())

func update_item_slot_display(item_index):
	var inventory_slot_display = container.get_child(item_index)
	var item = tools.items[item_index]
	inventory_slot_display.item_display(item)

func update_inventory_display():
	for item_index in tools.items.size():
		update_item_slot_display(item_index)

func on_items_updated(index):
	for item_index in index:
		update_item_slot_display(item_index)
	print(tools.items)

extends InventoryParent

func _process(delta):
	if Input.is_action_just_pressed("gui_tools") and !GuiMain.game_paused:
		GuiMain.game_paused = true
		update_inventory_display()
		$Animation.play("Open")
		$"%Tool1".button.grab_focus()
	elif Input.is_action_just_released("gui_tools") and GuiMain.game_paused:
		GuiMain.game_paused = false
		for child in container.get_children():
			if child.is_in_group("tool_button"):
				if child.get_node("Button").has_focus():
					child.destination.set_item(0, child.contained_item)
		$Animation.play("Exit")

#	if tools_open:
#		if Input.is_action_just_pressed("ui_right"):
#			container.set_start_angle_deg(lerp(container.get_start_angle_deg(), stepify(container.get_start_angle_deg() + -30, 30), 10 * delta))
#			print(container.get_start_angle_deg())

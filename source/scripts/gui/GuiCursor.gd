extends TextureRect

func _ready():
	get_viewport().connect("gui_focus_changed", self, "_on_gui_focus_changed")

func _on_gui_focus_changed(node: Node):
	rect_position = node.rect_position
	print(str(node))

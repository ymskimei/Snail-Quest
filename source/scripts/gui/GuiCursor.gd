extends CanvasLayer

onready var cursor: TextureRect = $Cursor
onready var anim: AnimationPlayer = $Cursor/AnimationPlayer

func _ready():
	get_viewport().connect("gui_focus_changed", self, "_on_gui_focus_changed")
	anim.play("CursorPulse")

func _on_gui_focus_changed(node: Node):
	cursor.rect_position = node.rect_global_position + (node.rect_size * 0.75)
	print(str(node))

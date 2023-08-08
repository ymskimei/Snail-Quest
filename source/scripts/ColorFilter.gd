tool
class_name ColorFilter
extends CanvasLayer

enum TYPES {
	None,
	Contrast,
	Monochrome,
	Protanopia,
	Deuteranopia,
	Tritanopia,
	Achromatopsia
}

export(TYPES) onready var type = TYPES.None setget set_type
var temp = null

var rect = ColorRect.new()

func _ready():
	GlobalManager.register_screen(self)
	self.add_child(self.rect)
	self.rect.rect_min_size = self.rect.get_viewport_rect().size
	self.rect.material = load("res://assets/materials/color_filter.material")
	self.rect.set_mouse_filter(Control.MOUSE_FILTER_IGNORE)
	if self.temp:
		self.Type = self.temp
		self.temp = null
	self.get_tree().root.connect('size_changed', self, '_on_viewport_size_changed')

func set_type(value):
	if rect.material:
		rect.material.set_shader_param("type", value)
	else:
		temp = value
	type = value

func get_type():
	return type

func _on_viewport_size_changed():
	self.rect.rect_min_size = self.rect.get_viewport_rect().size

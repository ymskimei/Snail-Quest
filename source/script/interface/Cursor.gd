extends CanvasLayer

onready var cursor: TextureRect = $Cursor
onready var anim: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	anim.play("CursorPulse")

func _process(delta: float) -> void:
	if is_instance_valid(Interface.current_focus):
		var node = Interface.current_focus
		var modifier = get_modifier_by_node(node)
		cursor.rect_position = lerp(cursor.rect_position, node.rect_global_position + modifier, 32.0 * delta) 

func get_modifier_by_node(n) -> Vector2:
	var mod = n.rect_size * 0.75
	if n is Button and n.text != "":
		if !n is OptionButton:
			mod = Vector2(n.rect_size.x * 0.5, n.rect_size.y * 0.5)
	elif n is LineEdit:
		mod = Vector2(n.rect_size.x, n.rect_size.y * 0.55)
	return mod

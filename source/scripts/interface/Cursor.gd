extends CanvasLayer

@onready var cursor: TextureRect = $Cursor
@onready var anim: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	anim.play("CursorPulse")

func _process(delta: float) -> void:
	if is_instance_valid(SB.game.interface.current_focus):
		var node = SB.game.interface.current_focus
		var modifier = get_modifier_by_node(node)
		cursor.position = lerp(cursor.position, node.global_position + modifier, 32.0 * delta) 

func get_modifier_by_node(n) -> Vector2:
	var mod = n.size * 0.75
	if n is Button and n.text != "":
		if !n is OptionButton:
			mod = Vector2(n.size.x * 1.1, n.size.y * 0.55)
	elif n is LineEdit:
		mod = Vector2(n.size.x, n.size.y * 0.55)
	return mod

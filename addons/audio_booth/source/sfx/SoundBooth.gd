extends Node
class_name SoundBooth

@onready var sfx := {}
@onready var sfx2D := {}
@onready var sfx3D := {}

func _ready() -> void:
	for child in _get_children_recursive(self, []):
		if child is Sound:
			sfx[child.name] = child
		if child is Sound2D:
			sfx2D[child.name] = child
		if child is Sound3D:
			sfx3D[child.name] = child

func play(sfx_name: String) -> void:
	if not sfx.has(sfx_name):
		print("Could not find Sound: %s" % sfx_name)
		return
	sfx[sfx_name].play_sfx()

func play2D(sfx_name: String, position := Vector2.ZERO) -> void:
	if not sfx2D.has(sfx_name):
		print("Could not find Sound2D: %s" % sfx_name)
		return
	sfx2D[sfx_name].play_at(position)

func play3D(sfx_name: String, position := Vector3.ZERO) -> void:
	if not sfx3D.has(sfx_name):
		print("Could not find Sound3D: %s" % sfx_name)
		return
	sfx3D[sfx_name].play_at(position)

func _get_children_recursive(node: Node, children: Array) -> Array:
	for child in node.get_children():
		if child is Sound or child is Sound2D or child is Sound3D:
			children.append(child)
		else:
			_get_children_recursive(child, children)
	return children

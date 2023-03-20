extends Spatial

export(Resource) var item

var tools = preload("res://resource/tools.tres")

onready var mesh : Mesh
onready var material : Material

func _ready():
	$"%MeshInstance".set_mesh(item.mesh)

func _on_Area_body_entered(body):
	if body.is_in_group("collector"):
		tools.add_item(item, 1)
		queue_free()

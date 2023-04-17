class_name Chunk
extends Object

var chunk_coord: Vector2
var resource: Resource

func _init(_chunk_coord: Vector2, _resource: Resource):
	chunk_coord = _chunk_coord
	resource = _resource

func real_pos() -> Vector3 :
	return Vector3(chunk_coord.x, 0, chunk_coord.y) * GlobalManager.chunk_size + Vector3(GlobalManager.chunk_size, 0, GlobalManager.chunk_size) / 2;

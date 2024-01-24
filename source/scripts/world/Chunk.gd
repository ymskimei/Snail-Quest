class_name Chunk
extends Object

var chunk_coord: Vector2 = Vector2.ZERO
var resource: Resource = null

func _init(_chunk_coord: Vector2, _resource: Resource):
	chunk_coord = _chunk_coord
	resource = _resource

func real_pos() -> Vector3:
	return Vector3(chunk_coord.x, 0, chunk_coord.y) * SB.chunk_size + Vector3(SB.chunk_size, 0, SB.chunk_size) / 2

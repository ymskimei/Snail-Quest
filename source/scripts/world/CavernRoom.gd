extends RigidBody2D

var size

func generate_room(_position, _size):
	position = _position
	size = _size
	var s = RectangleShape2D.new()
	s.custom_solver_bias = 1.0
	s.extents = size
	$CollisionShape2D.shape = s

extends Node2D

onready var cavern: TileMap = $TileMap

var room = preload("res://source/scenes/world/caverntest/cavern_room.tscn")

export var tile_size: int = 32
export var room_count: int = 32
export var min_size: int = 3
export var max_size: int = 6
export var h_spread: int = 100
export var w_spread: int = 0
export var cull: float = 0.5
export var max_corridor_width: int = 6
export var min_corridor_width: int = 3

export var is_constant_corridor_width: bool = true
export var randomize_corridor_width_every_step: bool = false

var path: AStar

func _ready() -> void:
	randomize()
	generate_rooms()

func _process(delta: float) -> void:
	update()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("action_main"):
		for n in $Rooms.get_children():
			n.queue_free()
		path = null
		generate_rooms()

#func generate_cavern():
#    yield(generate_rooms(), "completed")
#    generate_tiles()

func generate_rooms() -> void:
	for i in range(room_count):
		var pos = Vector2(rand_range(-h_spread, h_spread), rand_range(-w_spread, w_spread))
		var r = room.instance()
		var w = min_size + randi() % (max_size - min_size)
		var h = min_size + randi() % (max_size - min_size)
		r.generate_room(pos, Vector2(w, h) * tile_size)
		$Rooms.add_child(r)
	yield(get_tree().create_timer(0.2), "timeout")
	var room_coords: Array = []
	for room in $Rooms.get_children():
		if randf() < cull:
			room.queue_free()
		else:
			room.mode = RigidBody2D.MODE_STATIC
			room_coords.append(Vector3(room.position.x, room.position.y, 0))
	yield(get_tree(), "idle_frame")
	path = find_minimum_spanning_tree(room_coords)
	generate_tiles()

func find_minimum_spanning_tree(nodes) -> AStar:
	var path = AStar.new()
	path.add_point(path.get_available_point_id(), nodes.pop_front())
	while nodes:
		var min_distance = INF
		var min_position = null
		var current_position = null
		for point_1 in path.get_points():
			point_1 = path.get_point_position(point_1)
			for point_2 in nodes:
				if point_1.distance_to(point_2) < min_distance:
					min_distance = point_1.distance_to(point_2)
					min_position = point_2
					current_position = point_1
		var n = path.get_available_point_id()
		path.add_point(n, min_position)
		path.connect_points(path.get_closest_point(current_position), n)
		nodes.erase(min_position)
	return path

func _draw() -> void:
	for room in $Rooms.get_children():
		draw_rect(Rect2(room.position - room.size, room.size * 2), Color("FF8CBF"), false)
	if path:
		for p in path.get_points():
			for c in path.get_point_connections(p):
				var pp = path.get_point_position(p)
				var cp = path.get_point_position(c)
				draw_line(Vector2(pp.x, pp.y), Vector2(cp.x, cp.y), Color("FF8CBF"), 15, true)

func generate_tiles():
	cavern.clear()
	var full_rect = Rect2()
	for room in $Rooms.get_children():
		var r = Rect2(room.position - room.size, room.get_node("CollisionShape2D").shape.extents * 2)
		full_rect = full_rect.merge(r)
	var top_left = cavern.world_to_map(full_rect.position)
	var bottom_right = cavern.world_to_map(full_rect.end)
	var tunnels: Array = []
	for room in $Rooms.get_children():
		var size = (room.size / tile_size).floor()
		var pos = cavern.world_to_map(room.position)
		var upper_left = (room.position / tile_size).floor() - size
		for x in range(2, size.x * 2 - 1):
			for y in range(2, size.y * 2 - 1):
				cavern.set_cell(upper_left.x + x, upper_left.y + y, 0)
		var p = path.get_closest_point(Vector3(room.position.x, room.position.y, 0))
		for con in path.get_point_connections(p):
			if not con in tunnels:
				var start = cavern.world_to_map(Vector2(path.get_point_position(p).x, path.get_point_position(p).y))
				var end = cavern.world_to_map(Vector2(path.get_point_position(con).x, path.get_point_position(con).y))
				generate_tunnel(start, end)
		tunnels.append(p)
	cavern.update_bitmask_region()
	cavern.update_dirty_quadrants()

func generate_tunnel(pos_1, pos_2):
	var x_diff = sign(pos_2.x - pos_1.x)
	var y_diff = sign(pos_2.y - pos_1.y)
	if x_diff == 0: x_diff = pow(-1.0, randi() % 2)
	if y_diff == 0: y_diff = pow(-1.0, randi() % 2)
	var x_y = pos_1
	var y_x = pos_2
	if (randi() % 2) > 0:
		x_y = pos_2
		y_x = pos_1
	var corridor_width = max_corridor_width
	if not is_constant_corridor_width:
		corridor_width = floor(rand_range(min_corridor_width, max_corridor_width))
	for x in range(pos_1.x, pos_2.x, x_diff):
		if randomize_corridor_width_every_step:
			corridor_width = floor(rand_range(min_corridor_width, max_corridor_width))
		for w in (corridor_width - 1):
			cavern.set_cell(x, x_y.y + (y_diff * w), 0, false, false, false, Vector2(3, 3))
	for y in range(pos_1.y, pos_2.y, y_diff):
		if randomize_corridor_width_every_step:
			corridor_width = floor(rand_range(min_corridor_width, max_corridor_width))
		for w in (corridor_width - 1):
			cavern.set_cell(y_x.x + (x_diff * w), y, 0, false, false, false, Vector2(3, 3))

func get_random_room():
	var index = randi() % $Rooms.get_child_count()
	return $Rooms.get_child(index)

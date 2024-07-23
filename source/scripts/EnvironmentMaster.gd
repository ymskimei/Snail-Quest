extends Node

onready var shadow_material = preload("res://assets/materials/shadow.tres")

var light_sources: Array = []
#var shaded_meshes: Array = []

func make_material_unique(base_material: Material) -> Material:
	var new_material = base_material.duplicate()
	return new_material

func track_light_source(delta, self_location: Vector3, material: Material) -> void:
	var closest_light: Spatial
	var closest_light_distance: float
	var closest_light_direction: Vector3
	var minimum_distance = INF

	for l in light_sources:
		var distance = l.get_global_translation().distance_to(self_location)
		if distance < 16.0:
			if distance < minimum_distance:
				minimum_distance = distance
				closest_light = l
		else:
			closest_light = null

	if material.get_shader().has_param("light_direction"):
		var new_light_direction: Vector3
		if closest_light:
			new_light_direction = -(self_location - closest_light.get_global_translation()).normalized()
		else:
			new_light_direction = Vector3.UP
		closest_light_direction = lerp(material.get_shader_param("light_direction"), new_light_direction, 6.0 * delta)
		material.set_shader_param("light_direction", closest_light_direction)

	#Chucky wrote this:
	#*************///////////////////////////////------------
	#--------------------------------------------------------
	#--------------------------------------------------------
	#----------rttttt--------[[[[[[[[[[[[[]*]]]]]]]]]]]]

func reload_light_sources(scene: Spatial) -> void:
	light_sources.clear()
	light_sources = _get_light_sources(scene)
	print(light_sources)

func _get_light_sources(node: Node) -> Array:
	var result: Array = []
	for n in node.get_children():
		if n.is_in_group("light"):
			result.append(n)
		_get_light_sources(n)
	return result
#
#func reload_shaded_meshes(scene: Spatial) -> void:
#	shaded_meshes.clear()
#	shaded_meshes = _get_shaded_meshes(scene)
#	print(shaded_meshes)
#
#func _get_shaded_meshes(node: Node) -> Array:
#	var result: Array = []
#	for n in node.get_children():
#		if n is MeshInstance:
#			result.append(n.get_path())
#		_get_shaded_meshes(n)
#	return result

extends CanvasLayer

onready var loading: Label = $Label

var scenes: String = "res://source/scenes/world"
var materials: String = "res://assets/materials/"

var scene_cache: Array = []
var material_cache: Array = []

var scene_paths: Array = []
var material_paths: Array = []

signal scene_caching
signal material_caching
signal all_cached

var scene_thread: Thread = Thread.new()
var material_thread: Thread = Thread.new()

var cached: int = 0
var cache_ended: bool = false

func _ready() -> void:
	scene_paths.append_array(Utility.get_files(scenes, true, true))
	material_paths.append_array(Utility.get_files(materials, true, true))
	material_paths.append_array(Utility.get_files(materials, true, true))
	scene_thread.start(self, "_cache_scenes", "none", 2)
	material_thread.start(self, "_cache_materials", "none", 1)

func _process(delta: float):
	if is_instance_valid(loading):
		var loaded: float = scene_cache.size() + material_cache.size()
		var remaining: float = scene_paths.size() + material_paths.size()
		loading.text = str(Utility.roundf(loaded / remaining * 100, 1)) + "%"
	if !cache_ended and cached >= 2:
		call_deferred("emit_signal", "all_cached")
		print("Caching completed!")
		loading.queue_free()
		cache_ended = true

func _cache_scenes(none: String) -> void:
	print("Caching scenes...")
	for i in scene_paths.size():
		scene_cache.push_back(load(scene_paths[i]))
		call_deferred("emit_signal", "scene_caching", i + 1)
		print("Cached scene: " + str(scene_paths[i]))
	cached += 1

func _cache_materials(none: String) -> void:
	print("Caching materials...")
	for i in material_paths.size():
		material_cache.push_back(load(material_paths[i]))
		call_deferred("emit_signal", "material_caching", i + 1)
		print("Cached material: " + str(material_paths[i]))
	cached += 1

func _exit_tree() -> void:
	scene_thread.wait_to_finish()
	material_thread.wait_to_finish()

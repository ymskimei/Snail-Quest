extends RigidBody

export var identity: Resource = null

onready var armature = $Armature
onready var collision = $CollisionShape
onready var shell = $Armature/Skeleton/MeshInstance
onready var body = $Armature/Skeleton/Body
onready var eye_left = $Armature/Skeleton/BoneAttachment2/EyeLeft
onready var eye_right = $Armature/Skeleton/BoneAttachment/EyeRight

var entity_name: String = "Snail"

var body_size: float = 1
var shell_size: float = 1

var shell_mat: Material = null
var shell_accent_mat: Material = null
var shell_body_mat: Material = null
var body_mat: Material = null
var body_accent_mat: Material = null
var eye_left_mat: Material = null
var eye_right_mat: Material = null
var eyelid_left_mat: Material = null
var eyelid_right_mat: Material = null

var eyes_left: Array = []
var eyes_right: Array = []
var eye_patterns: Array = []
var eyelid_patterns: Array = []
var bodies: Array = []
var body_patterns: Array = []
var shells: Array = []
var shell_patterns: Array = []

func _ready() -> void:
	var meshes: String = "res://assets/model/"
	var textures: String = "res://assets/texture/entity/"
	eyes_left.append_array(Utility.get_loaded_files(meshes, "snail_eye_left", ".mesh"))
	eyes_right.append_array(Utility.get_loaded_files(meshes, "snail_eye_right", ".mesh"))
	eye_patterns.append_array(Utility.get_loaded_files(textures, "snail_eyes", ".png"))
	eyelid_patterns.append_array(Utility.get_loaded_files(textures, "snail_eyelids", ".png"))
	bodies.append_array(Utility.get_loaded_files(meshes, "snail_body", ".mesh"))
	body_patterns.append_array(Utility.get_loaded_files(textures, "snail_body_accent", ".png"))
	shells.append_array(Utility.get_loaded_files(meshes, "snail_shell", ".mesh"))
	shell_patterns.append_array(Utility.get_loaded_files(textures, "snail_shell_accent", ".png"))
	shell_mat = shell.get_surface_material(0)
	shell_accent_mat = shell.get_surface_material(0).get_next_pass()
	shell_body_mat = shell.get_surface_material(1)
	body_mat = body.get_surface_material(0)
	body_accent_mat = body.get_surface_material(0).get_next_pass()
	eye_left_mat = eye_left.get_surface_material(0).get_next_pass()
	eye_right_mat = eye_right.get_surface_material(0).get_next_pass()
	eyelid_left_mat = eye_left.get_surface_material(0).get_next_pass().get_next_pass()
	eyelid_right_mat = eye_right.get_surface_material(0).get_next_pass().get_next_pass()

func _physics_process(delta: float) -> void:
	update_appearance()

func set_entity_name(new_text: String) -> void:
	identity.entity_name = new_text

func set_entity_scale(value: float) -> void:
	identity.entity_scale = value / 50

func set_entity_eyes(next: bool = true):
	identity.mesh_eye_left = eyes_left[Utility.array_cycle(eye_left.get_mesh(), eyes_left, next)]
	identity.mesh_eye_right = eyes_right[Utility.array_cycle(eye_right.get_mesh(), eyes_right, next)]

func set_entity_pupils(next: bool = true):
	identity.pattern_eyes = eye_patterns[Utility.array_cycle(eye_right_mat.get_shader_param("texture_albedo"), eye_patterns, next)]

func set_entity_eyelids(next: bool = true):
	identity.pattern_eyelids = eyelid_patterns[ Utility.array_cycle(eyelid_right_mat.get_shader_param("texture_albedo"), eyelid_patterns, next)]

func set_entity_body(next: bool = true):
	identity.mesh_body = bodies[Utility.array_cycle(body.get_mesh(), bodies, next)]

func set_entity_pattern(next: bool = true):
	identity.pattern_body = body_patterns[Utility.array_cycle(body_accent_mat.get_shader_param("texture_albedo"), body_patterns, next)]

func set_entity_shell(next: bool = true):
	identity.mesh_shell = shells[Utility.array_cycle(shell.get_mesh(), shells, next)]
	
func set_entity_swirl(next: bool = true):
	identity.pattern_shell = shell_patterns[Utility.array_cycle(shell_accent_mat.get_shader_param("texture_albedo"), shell_patterns, next)]

func set_color_shell(c: Color) -> void:
	identity.color_shell_base = c

func set_color_shell_accent(c: Color) -> void:
	identity.color_shell_accent = c

func set_color_body(c: Color) -> void:
	identity.color_body_base = c

func set_color_body_accent(c: Color) -> void:
	identity.color_body_accent = c

func set_color_eyes(c: Color) -> void:
	identity.color_eyes = c

func run_randomizer() -> void:
	randomize()
	set_entity_name(_get_random_name())
	set_entity_scale(int(rand_range(20, 100)))
	for i in _get_random_amount():
		set_entity_eyes()
	for i in _get_random_amount():
		set_entity_pupils()
	for i in _get_random_amount():
		set_entity_eyelids()
	for i in _get_random_amount():
		set_entity_body()
	for i in _get_random_amount():
		set_entity_pattern()
	for i in _get_random_amount():
		set_entity_shell()
	for i in _get_random_amount():
		set_entity_swirl()
	set_color_shell(_get_random_color())
	set_color_shell_accent(_get_random_color())
	set_color_body(_get_random_color())
	set_color_body_accent(_get_random_color())
	set_color_eyes(_get_random_color())

func _get_random_amount() -> int:
	randomize()
	var num = int(rand_range(1, int(rand_range(10, 20))))
	return num

func _get_random_color() -> Color:
	var color = Color(clamp(randf(), 0.2, 0.7), clamp(randf(), 0.2, 0.7), clamp(randf(), 0.2, 0.7))
	return color

func _get_random_name() -> String:
	var possible_names: Array = [
		"slumpy", "glooper", "poki", "shmush", "slunkly", "snaily",
		"sluggy", "goober", "poots", "glompulous", "buggy", "shmucker",
		"blobby", "dubbington", "klonk", "shwinkle", "slurpo", "fishy",
		"amonculous", "clobby", "haru", "jumbo", "baby", "quaggle",
		"bartholomew ", "bozo", "lumpy", "bloob", "ginort", "nooty",
		"snooty", "king", "mimi", "rika", "quartz", "kai"]
	var prob: int = randi() % 10 + 1
	if prob <= 8:
		return _make_random_name()
	else:
		return possible_names[randi() % possible_names.size()].capitalize()

func _make_random_name() -> String:
	var first_char: Array = ["b", "d", "g", "h", "j", "k", "l", "m", "n", "p", "r", "s", "t", "v", "w", "z"]
	var first_char_alts: Array = ["sh", "fl", "shm", "shl", "bl", "ch", "kl", "pl", "sm"]
	var first_char_full: Array = []
	first_char_full.append_array(first_char)
	first_char_full.append_array(first_char_alts)
	var end_char: Array = ["y", "oo", "u", "a", "ee", "ya"]
	var end_char_alts: Array = ["ulous", "ook", "ooga", "osmosis", "ai", "ington", "er"]
	var end_char_full: Array = []
	end_char_full.append_array(end_char)
	end_char_full.append_array(end_char_alts)
	var start: String = first_char_full[randi() % first_char_full.size()]
	var middle: String = end_char[randi() % end_char.size()]
	var end_in_vowel: bool = randi() % 2
	var end_vowels: String = ""
	if end_in_vowel:
		end_vowels = end_char_full[randi() % end_char_full.size()]
	var end: String = first_char[randi() % first_char.size()] + end_vowels
	var new_name: String = start + middle + end
	return new_name.capitalize()

func update_appearance() -> void:
	shell.set_mesh(identity.mesh_shell)
	body.set_mesh(identity.mesh_body)
	eye_left.set_mesh(identity.mesh_eye_left)
	eye_right.set_mesh(identity.mesh_eye_right)
	shell_accent_mat.set_shader_param("texture_albedo", identity.pattern_shell)
	eye_left_mat.set_shader_param("texture_albedo", identity.pattern_eyes)
	eye_right_mat.set_shader_param("texture_albedo", identity.pattern_eyes)
	shell_mat.set_shader_param("albedo_color", identity.color_shell_base)
	shell_mat.set_shader_param("shade_color", identity.color_shell_base.darkened(0.2))
	shell_accent_mat.set_shader_param("albedo_color", identity.color_shell_accent)
	shell_body_mat.set_shader_param("albedo_color", identity.color_body_base)
	shell_body_mat.set_shader_param("shade_color", identity.color_body_base.darkened(0.2))
	body_mat.set_shader_param("specular_color", identity.color_body_base.lightened(0.4))
	body_mat.set_shader_param("rim_color", identity.color_body_base.lightened(0.4))
	body_mat.set_shader_param("albedo_color", identity.color_body_base)
	body_mat.set_shader_param("shade_color", identity.color_body_base.darkened(0.2))
	body_accent_mat.set_shader_param("texture_albedo", identity.pattern_body)
	body_accent_mat.set_shader_param("albedo_color", identity.color_body_accent)
	eye_left_mat.set_shader_param("albedo_color", identity.color_eyes)
	eye_right_mat.set_shader_param("albedo_color", identity.color_eyes)
	eyelid_left_mat.set_shader_param("texture_albedo", identity.pattern_eyelids)
	eyelid_right_mat.set_shader_param("texture_albedo", identity.pattern_eyelids)
	eyelid_left_mat.set_shader_param("albedo_color", identity.color_body_accent)
	eyelid_right_mat.set_shader_param("albedo_color", identity.color_body_accent)
	armature.scale = Vector3(identity.entity_scale, identity.entity_scale, identity.entity_scale)
	collision.shape.radius = identity.entity_scale

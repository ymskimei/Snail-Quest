extends RigidBody

export var identity: Resource = null

onready var armature: Spatial = $Armature
onready var collision: CollisionShape = $CollisionShape
onready var shell: MeshInstance = $Armature/Skeleton/MeshInstance
onready var body: MeshInstance = $Armature/Skeleton/Body
onready var eye_left: MeshInstance = $Armature/Skeleton/BoneAttachment2/EyeLeft
onready var eye_right: MeshInstance = $Armature/Skeleton/BoneAttachment/EyeRight
onready var hat: MeshInstance = $Armature/Skeleton/BoneAttachment3/Hat
onready var sticker: MeshInstance = $Armature/Skeleton/BoneAttachment3/Sticker
onready var anim: AnimationPlayer = $AnimationPlayer

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

var shell_mat: Material = null
var shell_accent_mat: Material = null
var shell_body_mat: Material = null
var body_mat: Material = null
var body_accent_mat: Material = null
var eye_left_mat: Material = null
var eye_right_mat: Material = null
var eyelid_left_mat: Material = null
var eyelid_right_mat: Material = null
var hat_mat: Material = null
var sticker_mat: Material = null

var eyes_left: Array = []
var eyes_right: Array = []
var eye_patterns: Array = []
var eyelid_patterns: Array = []
var bodies: Array = []
var body_patterns: Array = []
var shells: Array = []
var shell_patterns: Array = []
var stickers: Array = []
var hats: Array = []
var hat_patterns: Array = []

var lightener = Color("FFF4DB")
var darkener = Color("0E0B3A")

func _ready() -> void:
	shell_mat = shell.get_surface_material(0)
	shell_accent_mat = shell.get_surface_material(0).get_next_pass()
	shell_body_mat = shell.get_surface_material(1)
	body_mat = body.get_surface_material(0)
	body_accent_mat = body.get_surface_material(0).get_next_pass()
	eye_left_mat = eye_left.get_surface_material(0).get_next_pass()
	eye_right_mat = eye_right.get_surface_material(0).get_next_pass()
	eyelid_left_mat = eye_left.get_surface_material(0).get_next_pass().get_next_pass()
	eyelid_right_mat = eye_right.get_surface_material(0).get_next_pass().get_next_pass()
	hat_mat = hat.get_surface_material(0)
	sticker_mat = sticker.get_surface_material(0)
	_update_appearance_arrays()
	lightener.a = 0.4
	darkener.a = 0.2
	anim.play("SnailIdle")

func _physics_process(delta: float) -> void:
	update_appearance()

func set_entity_name(new_text: String) -> void:
	identity.set_entity_name(new_text)

func set_entity_scale(value: float) -> void:
	identity.set_entity_scale(value / 50)

func set_entity_shell(next: bool = true):
	identity.set_mesh_shell(shells[Utility.array_cycle(shell.get_mesh(), shells, next)])
	_reposition_outfit()

func set_entity_body(next: bool = true):
	identity.set_mesh_body(bodies[Utility.array_cycle(body.get_mesh(), bodies, next)])

func set_entity_eyes(next: bool = true):
	identity.set_mesh_eye_left(eyes_left[Utility.array_cycle(eye_left.get_mesh(), eyes_left, next)])
	identity.set_mesh_eye_right(eyes_right[Utility.array_cycle(eye_right.get_mesh(), eyes_right, next)])
	
func set_entity_hat(next: bool = true):
	identity.set_mesh_hat([Utility.array_cycle(hat.get_mesh(), hats, next)])
	identity.set_pattern_hat(hat_patterns[Utility.array_cycle(hat_mat.get_shader_param("texture_albedo"), hat_patterns, next)])

func set_color_shell(c: Color) -> void:
	identity.set_color_shell_base(c)

func set_color_shell_accent(c: Color) -> void:
	identity.set_color_shell_accent(c)

func set_color_body(c: Color) -> void:
	identity.set_color_body_base(c)

func set_color_body_accent(c: Color) -> void:
	identity.set_color_body_accent(c)

func set_color_eyes(c: Color) -> void:
	identity.set_color_eyes(c)

func set_entity_pupils(next: bool = true):
	identity.set_pattern_eyes(eye_patterns[Utility.array_cycle(eye_right_mat.get_shader_param("texture_albedo"), eye_patterns, next)])

func set_entity_eyelids(next: bool = true):
	identity.set_pattern_eyelids(eyelid_patterns[ Utility.array_cycle(eyelid_right_mat.get_shader_param("texture_albedo"), eyelid_patterns, next)])

func set_entity_pattern(next: bool = true):
	identity.set_pattern_body(body_patterns[Utility.array_cycle(body_accent_mat.get_shader_param("texture_albedo"), body_patterns, next)])

func set_entity_swirl(next: bool = true):
	identity.set_pattern_shell(shell_patterns[Utility.array_cycle(shell_accent_mat.get_shader_param("texture_albedo"), shell_patterns, next)])

func set_entity_sticker(next: bool = true):
	identity.set_pattern_sticker(stickers[Utility.array_cycle(sticker_mat.get_shader_param("texture_albedo"), stickers, next)])

func run_randomizer() -> void:
	randomize()
	set_entity_name(_get_random_name())
	set_entity_scale(get_ramped_random_amount(20, 100))
	if randi() % 5 == 1:
		for i in _get_random_amount():
			set_entity_eyes()
	else:
		identity.set_mesh_eye_left(eyes_left[0])
		identity.set_mesh_eye_right(eyes_right[0])
	for i in _get_random_amount():
		set_entity_pupils()
	if randi() % 5 == 1:
		for i in _get_random_amount():
			set_entity_eyelids()
	else:
		identity.set_pattern_eyelids(eyelid_patterns[0])
	for i in _get_random_amount():
		set_entity_body()
	for i in _get_random_amount():
		set_entity_pattern()
	for i in _get_random_amount():
		set_entity_shell()
	for i in _get_random_amount():
		set_entity_swirl()
	if randi() % 6 == 1:
		for i in _get_random_amount():
			set_entity_sticker()
	else:
		identity.set_pattern_sticker(stickers[0])
	if randi() % 10 == 1:
		for i in _get_random_amount():
			set_entity_hat()
	else:
		identity.set_mesh_hat(hats[0])
		identity.set_pattern_hat(hat_patterns[0])
	var body_color = _get_random_color()
	var shell_color = _get_random_color()
	var shell_color_accent = _get_random_color()
	if body_color.get_luminance() <= 0.5:
		if shell_color.get_luminance() <= 0.5:
			shell_color = shell_color.blend(darkener)
	else:
		if shell_color.get_luminance() > 0.5:
			shell_color = shell_color.blend(lightener)
	if shell_color.get_luminance() > 0.5:
		shell_color_accent = shell_color_accent.blend(lightener)
	else:
		shell_color_accent = shell_color_accent.blend(darkener)
	if body_color.is_equal_approx(shell_color):
		body_color = body_color.inverted()
	if !randi() % 3 == 1:
		shell_color_accent = shell_color.blend(darkener).darkened(0.2)
	set_color_body(body_color)
	set_color_body_accent(_get_random_color().blend(Color(body_color.r, body_color.g, body_color.b, 0.4)))
	set_color_shell(shell_color)
	set_color_shell_accent(shell_color_accent)
	set_color_eyes(_get_random_color())

func save_resource(path) -> void:
	var full_path = path + identity.get_entity_name().to_lower() + ".tres"
	ResourceSaver.save(full_path, identity)

func load_resource(path) -> void:
	identity = ResourceLoader.load(path)

func _get_random_amount() -> int:
	randomize()
	var num = rng.randi_range(1, rng.randi_range(10, 20))
	return num

func get_ramped_random_amount(minimum: float, maximum: float):
	var mean: float = (minimum + maximum) / 2.0
	var deviation: float = (maximum - minimum) / 10.0
	var bias: float = 0.8
	mean = clamp(mean, minimum, maximum)
	deviation = clamp(deviation, 0.1, (maximum - minimum) / 2.0)
	var value = clamp(rng.randfn(mean, deviation), minimum, maximum)
	return value

func _get_random_color() -> Color:
	var color = Color(clamp(randf(), 0.2, 0.7), clamp(randf(), 0.2, 0.7), clamp(randf(), 0.2, 0.7))
	return color

func _get_random_name() -> String:
	var possible_names: Array = [
		"slumpy", "glooper", "poki", "shmush", "slunkly",
		"goober", "poots", "glompulous", "buggy", "shmucker",
		"blobby", "dubbington", "klonk", "shwinkle", "slurpo",
		"amonculous", "weezer", "haru", "jumbo", "quaggle",
		"bozo", "gay", "bloob", "ginort", "nooty",
		"snooty", "king", "mimi", "kwartz", "kai", "pheph",
		"chaos", "armageddon", "delta", "shelby", "bob"]
	var blacklisted_names: Array = [
		"chud", "jap", "klan", "slur", "vag", "smut", ""]
	var fallback_name: String = possible_names[randi() % possible_names.size()].capitalize()
	if randi() % 100 <= 95:
		var created_name = _make_random_name()
		if created_name.length() >= 3 and !blacklisted_names.has(created_name):
			return created_name.capitalize()
	return fallback_name

func _make_random_name() -> String:
	var first_char: Array = ["b", "d", "g", "h", "j", "k", "l", "m", "n", "p", "r", "s", "t", "v", "w", "z"]
	var first_char_alts: Array = ["sh", "fl", "shm", "shl", "bl", "ch", "kl", "pl", "sm"]
	var first_char_full: Array = []
	first_char_full.append_array(first_char)
	first_char_full.append_array(first_char_alts)
	var end_char: Array = ["oo", "u", "a", "ee"]
	var end_char_alts: Array = ["zu", "y", "ay", "ya", "ulous", "ooga", "osis", "ai", "ington", "er", "osmo", "inkle", "us", "arkle"]
	var end_char_full: Array = []
	end_char_full.append_array(end_char)
	end_char_full.append_array(end_char_alts)
	var start: String = ""
	if randi() % 2 == 1:
		start = first_char_full[randi() % first_char_full.size()]
	var middle: String = end_char[randi() % end_char.size()]
	var longer_end: String = ""
	if randi() % 2 == 1:
		longer_end = end_char_full[randi() % end_char_full.size()]
	var end: String = first_char[randi() % first_char.size()] + longer_end
	var new_name: String = ""
	if !new_name.ends_with("y"):
		new_name = first_char_full[randi() % first_char_full.size()] + middle + end
	else:
		if randi() % 3 == 1:
			new_name = start + middle + end_char[randi() % end_char.size()]
	if new_name.ends_with("j") or new_name.ends_with("w"):
		new_name.erase(new_name.length() - 1, 1)
	if new_name.begins_with("nk"):
		new_name.erase(0, 2)
	return new_name

func _reposition_outfit() -> void:
	var sticker_pos_x: float  = 0
	var sticker_pos_y: float  = 0
	var sticker_rot: float = 0
	var hat_pos_x: float = 0
	var hat_pos_y: float = 0
	var hat_rot_x: float = 0
	var hat_rot_z: float = 0
	match shells.find(identity.get_mesh_shell()):
		0:
			sticker_pos_x -= 0
			sticker_pos_y += -0.1
			sticker_rot = 0
			hat_pos_x -= 0
			hat_pos_y -= 0.02
			hat_rot_x = 8
			hat_rot_z = 0
		1:
			sticker_pos_x -= 0.2
			sticker_pos_y += 0.25
			sticker_rot = 90
			hat_pos_x -= 0
			hat_pos_y += 0.45
			hat_rot_x = 0
			hat_rot_z = -10
		2:
			sticker_pos_x -= 0.2
			sticker_pos_y += 0.25
			sticker_rot = 90
			hat_pos_x -= 0
			hat_pos_y += 0.45
			hat_rot_x = -5
			hat_rot_z = 0
		3:
			sticker_pos_x -= 0.3
			sticker_pos_y += 0.11
			sticker_rot = 90
			hat_pos_x -= 0
			hat_pos_y += 0.2
			hat_rot_x = 0
			hat_rot_z = -15
		4:
			sticker_pos_x -= 0.2
			sticker_pos_y += 0.25
			sticker_rot = 90
			hat_pos_x -= 0
			hat_pos_y += 0.45
			hat_rot_x = 0
			hat_rot_z = -10
		5:
			sticker_pos_x -= 0.1
			sticker_pos_y += 0.25
			sticker_rot = 50
			hat_pos_x += 0.1
			hat_pos_y += 0.2
			hat_rot_x = -15
			hat_rot_z = -10
		6:
			sticker_pos_x -= 0.5
			sticker_pos_y += 0.25
			sticker_rot = 90
			hat_pos_x -= 0
			hat_pos_y += 0.53
			hat_rot_x = -4
			hat_rot_z = -4
		7:
			sticker_pos_x -= 0.2
			sticker_pos_y += 0.25
			sticker_rot = 90
			hat_pos_x -= 0
			hat_pos_y += 0.45
			hat_rot_x = 0
			hat_rot_z = 0
	sticker.translation.x = sticker_pos_x
	sticker.translation.y = sticker_pos_y
	sticker.rotation_degrees.x = sticker_rot
	hat.translation.x = hat_pos_x
	hat.translation.y = hat_pos_y
	hat.rotation_degrees.x = hat_rot_x
	hat.rotation_degrees.z = hat_rot_z

func _update_appearance_arrays() -> void:
	var meshes: String = "res://assets/model/"
	var textures: String = "res://assets/texture/"
	eyes_left.append_array(Utility.get_loaded_files(meshes, "entity/snail_eye_left", ".mesh"))
	eyes_right.append_array(Utility.get_loaded_files(meshes, "entity/snail_eye_right", ".mesh"))
	eye_patterns.append_array(Utility.get_loaded_files(textures, "entity/snail_eyes", ".png"))
	eyelid_patterns.append_array(Utility.get_loaded_files(textures, "entity/snail_eyelids", ".png"))
	bodies.append_array(Utility.get_loaded_files(meshes, "entity/snail_body", ".mesh"))
	body_patterns.append_array(Utility.get_loaded_files(textures, "entity/snail_body_accent", ".png"))
	shells.append_array(Utility.get_loaded_files(meshes, "entity/snail_shell", ".mesh"))
	shell_patterns.append_array(Utility.get_loaded_files(textures, "entity/snail_shell_accent", ".png"))
	stickers.append_array(Utility.get_loaded_files(textures, "object/sticker", ".png"))
	hats.append_array(Utility.get_loaded_files(meshes, "object/hat", ".mesh"))
	hat_patterns.append_array(Utility.get_loaded_files(textures, "object/hat", ".png"))

func update_appearance() -> void:
	armature.scale = Vector3(identity.get_entity_scale(), identity.get_entity_scale(), identity.get_entity_scale())
	collision.shape.radius = identity.get_entity_scale()
	shell.set_mesh(identity.get_mesh_shell())
	body.set_mesh(identity.get_mesh_body())
	eye_left.set_mesh(identity.get_mesh_eye_left())
	eye_right.set_mesh(identity.get_mesh_eye_right())
	shell_accent_mat.set_shader_param("texture_albedo", identity.get_pattern_shell())
	eye_left_mat.set_shader_param("texture_albedo", identity.get_pattern_eyes())
	eye_right_mat.set_shader_param("texture_albedo", identity.get_pattern_eyes())
	shell_mat.set_shader_param("albedo_color", identity.get_color_shell_base())
	shell_mat.set_shader_param("shade_color", identity.get_color_shell_base().blend(darkener))
	shell_accent_mat.set_shader_param("albedo_color", identity.get_color_shell_accent())
	shell_body_mat.set_shader_param("albedo_color", identity.get_color_body_base())
	shell_body_mat.set_shader_param("shade_color", identity.get_color_body_base().blend(darkener))
	body_mat.set_shader_param("specular_color", identity.get_color_body_base().blend(lightener))
	body_mat.set_shader_param("rim_color", identity.get_color_body_base().blend(lightener))
	body_mat.set_shader_param("albedo_color", identity.get_color_body_base())
	body_mat.set_shader_param("shade_color", identity.get_color_body_base().blend(darkener))
	body_accent_mat.set_shader_param("texture_albedo", identity.get_pattern_body())
	body_accent_mat.set_shader_param("albedo_color", identity.get_color_body_accent())
	eye_left_mat.set_shader_param("albedo_color", identity.get_color_eyes())
	eye_right_mat.set_shader_param("albedo_color", identity.get_color_eyes())
	eyelid_left_mat.set_shader_param("texture_albedo", identity.get_pattern_eyelids())
	eyelid_right_mat.set_shader_param("texture_albedo", identity.get_pattern_eyelids())
	eyelid_left_mat.set_shader_param("albedo_color", identity.get_color_body_base().blend(darkener))
	eyelid_right_mat.set_shader_param("albedo_color", identity.get_color_body_base().blend(darkener))
	hat.set_mesh(identity.get_mesh_hat())
	hat_mat.set_shader_param("texture_albedo", identity.get_pattern_hat())
	sticker_mat.set_shader_param("texture_albedo", identity.get_pattern_sticker())

func _notification(what):
	match what:
		NOTIFICATION_WM_FOCUS_IN:
			_update_appearance_arrays()

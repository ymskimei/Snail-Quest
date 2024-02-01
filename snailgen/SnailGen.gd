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

var shell_type: Mesh = null
var shell_accent_type: Texture = null
var body_type: Mesh = null
var body_accent_type: Texture = null
var eye_type: Mesh = null

var shell_mat: Material = null
var shell_accent_mat: Material = null
var body_mat: Material = null
var body_accent_mat: Material = null
var eye_left_mat: Material = null
var eye_right_mat: Material = null
var eyelid_left_mat: Material = null
var eyelid_right_mat: Material = null

var shell_color: Color = Color("FFFFFF")
var shell_accent_color: Color = Color("FFFFFF")
var body_color: Color = Color("FFFFFF")
var body_accent_color: Color = Color("FFFFFF")
var eye_color: Color = Color("FFFFFF")

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
	body_mat = body.get_surface_material(0)
	body_accent_mat = body.get_surface_material(0).get_next_pass()
	eye_left_mat = eye_left.get_surface_material(0).get_next_pass()
	eye_right_mat = eye_right.get_surface_material(0).get_next_pass()
	eyelid_left_mat = eye_left.get_surface_material(0).get_next_pass().get_next_pass()
	eyelid_right_mat = eye_right.get_surface_material(0).get_next_pass().get_next_pass()
	shell_color = identity.color_shell_base
	shell_accent_color = identity.color_shell_accent
	body_color = identity.color_body
	body_accent_color = identity.color_body_accent
	eye_color = identity.color_eyes
	update_appearance()

func _physics_process(delta: float) -> void:
	update_colors()

func set_entity_name(new_text: String) -> void:
	entity_name = new_text

func set_entity_scale(value: float) -> void:
	var size = value / 50
	armature.scale = Vector3(size, size, size)
	collision.shape.radius = size

func set_entity_eyes(next: bool = true):
	eye_left.set_mesh(eyes_left[Utility.array_cycle(eye_left.get_mesh(), eyes_left, next)])
	eye_right.set_mesh(eyes_right[Utility.array_cycle(eye_right.get_mesh(), eyes_right, next)])

func set_entity_pupils(next: bool = true):
	eye_left_mat.set_shader_param("texture_albedo", eye_patterns[Utility.array_cycle(eye_left_mat.get_shader_param("texture_albedo"), eye_patterns, next)])
	eye_right_mat.set_shader_param("texture_albedo", eye_patterns[Utility.array_cycle(eye_right_mat.get_shader_param("texture_albedo"), eye_patterns, next)])

func set_entity_eyelids(next: bool = true):
	eyelid_left_mat.set_shader_param("texture_albedo", eyelid_patterns[Utility.array_cycle(eyelid_left_mat.get_shader_param("texture_albedo"), eyelid_patterns, next)])
	eyelid_right_mat.set_shader_param("texture_albedo",eyelid_patterns[ Utility.array_cycle(eyelid_right_mat.get_shader_param("texture_albedo"), eyelid_patterns, next)])

func set_entity_body(next: bool = true):
	body.set_mesh(bodies[Utility.array_cycle(body.get_mesh(), bodies, next)])

func set_entity_pattern(next: bool = true):
	body_accent_mat.set_shader_param("texture_albedo", body_patterns[Utility.array_cycle(body_accent_mat.get_shader_param("texture_albedo"), body_patterns, next)])

func set_entity_shell(next: bool = true):
	shell.set_mesh(shells[Utility.array_cycle(shell.get_mesh(), shells, next)])
	
func set_entity_swirl(next: bool = true):
	shell_accent_mat.set_shader_param("texture_albedo", shell_patterns[Utility.array_cycle(shell_accent_mat.get_shader_param("texture_albedo"), shell_patterns, next)])

func update_colors() -> void:
	shell_mat.set_shader_param("albedo_color", shell_color)
	shell_mat.set_shader_param("shade_color", shell_color.darkened(0.2))
	shell_accent_mat.set_shader_param("albedo_color", shell_accent_color)
	body_mat.set_shader_param("specular_color", body_color.lightened(0.4))
	body_mat.set_shader_param("rim_color", body_color.lightened(0.4))
	body_mat.set_shader_param("albedo_color", body_color)
	body_mat.set_shader_param("shade_color", body_color.darkened(0.2))
	body_accent_mat.set_shader_param("albedo_color", body_accent_color)
	eye_left_mat.set_shader_param("albedo_color", eye_color)
	eye_right_mat.set_shader_param("albedo_color", eye_color)
	eyelid_left_mat.set_shader_param("albedo_color", body_accent_color)
	eyelid_right_mat.set_shader_param("albedo_color", body_accent_color)

func update_appearance() -> void:
	shell.set_mesh(identity.mesh_shell)
	body.set_mesh(identity.mesh_body)
	eye_left.set_mesh(identity.mesh_eye_left)
	eye_right.set_mesh(identity.mesh_eye_right)
	shell_accent_mat.set_shader_param("texture_albedo", identity.pattern_shell)
	eye_left_mat.set_shader_param("texture_albedo", identity.pattern_eyes)
	eye_right_mat.set_shader_param("texture_albedo", identity.pattern_eyes)
	shell_mat.set_shader_param("albedo_color", identity.color_shell_base)
	shell_mat.set_shader_param("shade_color", identity.color_shell_base_shade)
	shell_accent_mat.set_shader_param("albedo_color", identity.color_shell_accent)
	body_mat.set_shader_param("specular_color", identity.color_body_specular)
	body_mat.set_shader_param("rim_color", identity.color_body_specular)
	body_mat.set_shader_param("albedo_color", identity.color_body)
	body_mat.set_shader_param("shade_color", identity.color_body_shade)
	body_accent_mat.set_shader_param("texture_albedo", identity.pattern_body)
	body_accent_mat.set_shader_param("albedo_color", identity.color_body_accent)
	eye_left_mat.set_shader_param("albedo_color", identity.color_eyes)
	eye_right_mat.set_shader_param("albedo_color", identity.color_eyes)
	eyelid_left_mat.set_shader_param("texture_albedo", identity.pattern_eyelids)
	eyelid_right_mat.set_shader_param("texture_albedo", identity.pattern_eyelids)
	eyelid_left_mat.set_shader_param("albedo_color", identity.color_body_accent)
	eyelid_right_mat.set_shader_param("albedo_color", identity.color_body_accent)

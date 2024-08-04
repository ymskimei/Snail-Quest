class_name Snail
extends Entity

onready var body = $Armature/Skeleton/Body
onready var eye_left = $Armature/Skeleton/BoneAttachment2/EyeLeft
onready var eye_right = $Armature/Skeleton/BoneAttachment/EyeRight

onready var affect_area: Area = $AffectArea

onready var anim_tree: AnimationTree = $AnimationTree
onready var anim: AnimationPlayer = $AnimationPlayer

onready var anim_states: AnimationNodeStateMachinePlayback = anim_tree.get("parameters/playback")

var boosting: bool = false
#var temporary_exhaustion: bool = false

var can_jump: bool = false
var can_turn: bool = true
var can_roll: bool = true

func _ready() -> void:
	mesh = $Armature/Skeleton/MeshInstance
	
	states.ready(self)
	update_appearance()
	set_interaction_text("")

	eye_blinking_init(eye_left.get_surface_material(0), eye_right.get_surface_material(0))

func _input(event: InputEvent) -> void:
	if is_controlled():
		states.input(event)

func _unhandled_input(event: InputEvent) -> void:
	if is_controlled():
		states.unhandled_input(event)

func _physics_process(delta: float) -> void:
	#update_appearance()
	if is_controlled():
		states.physics_process(delta)
	else:
		move_and_slide((Vector3.DOWN * 2) * ProjectSettings.get_setting("physics/3d/default_gravity"), Vector3.UP, false, 8, 0.785398, false)

		anim_states.travel("SnailIdle")
		var amount: float = 0
		match get_entity_identity().get_entity_personality():
			1:
				amount = 1.0
			2:
				amount = -1.0
			_:
				amount = 0.0
		anim_tree.set("parameters/SnailIdle/Blend3/blend_amount", amount)

	set_looking_target()
	eye_tracking_behavior(delta, eye_left.get_surface_material(0), eye_right.get_surface_material(0))
	
func _on_proximity_entered(b) -> void:
	if b is Enemy:
		enemy_found = true

func _on_proximity_exited(b) -> void:
	if b is Enemy:
		enemy_found = false

func update_appearance() -> void:
	var shell_mat = mesh.get_surface_material(0)
	var shell_opening = mesh.get_surface_material(1)
	var shell_accent_mat = mesh.get_surface_material(0).get_next_pass()
	var body_mat = body.get_surface_material(0)
	var body_accent_mat = body.get_surface_material(0).get_next_pass()
	var eye_left_mat = eye_left.get_surface_material(0).get_next_pass()
	var eye_right_mat = eye_right.get_surface_material(0).get_next_pass()
	var eyelid_left_mat = eye_left.get_surface_material(0).get_next_pass().get_next_pass()
	var eyelid_right_mat = eye_right.get_surface_material(0).get_next_pass().get_next_pass()
	if identity:
		mesh.set_mesh(identity.mesh_shell)
		body.set_mesh(identity.mesh_body)
		eye_left.set_mesh(identity.mesh_eye_left)
		eye_right.set_mesh(identity.mesh_eye_right)

		shell_accent_mat.set_shader_param("texture_albedo", identity.pattern_shell)

		eye_left_mat.set_shader_param("texture_albedo", identity.pattern_eyes)
		eye_right_mat.set_shader_param("texture_albedo", identity.pattern_eyes)

		shell_mat.set_shader_param("albedo_color", identity.color_shell_base)
		shell_mat.set_shader_param("shade_color", identity.color_shell_shade)
		shell_opening.set_shader_param("albedo_color", identity.color_body_base)
		shell_opening.set_shader_param("shade_color", identity.color_body_shade)

		shell_accent_mat.set_shader_param("albedo_color", identity.color_shell_accent)
		shell_accent_mat.set_shader_param("shade_color", identity.color_shell_accent)

		body_mat.set_shader_param("specular_color", identity.color_body_specular)
		body_mat.set_shader_param("rim_color", identity.color_body_specular)
		body_mat.set_shader_param("albedo_color", identity.color_body_base)
		body_mat.set_shader_param("shade_color", identity.color_body_shade)

		body_accent_mat.set_shader_param("texture_albedo", identity.pattern_body)
		body_accent_mat.set_shader_param("albedo_color", identity.color_body_accent)
		body_accent_mat.set_shader_param("shade_color", identity.color_body_shade)

		eye_left_mat.set_shader_param("albedo_color", identity.color_eyes)
		eye_left_mat.set_shader_param("shade_color", identity.color_eyes)
		eye_right_mat.set_shader_param("albedo_color", identity.color_eyes)
		eye_right_mat.set_shader_param("shade_color", identity.color_eyes)

		eyelid_left_mat.set_shader_param("texture_albedo", identity.pattern_eyelids)
		eyelid_right_mat.set_shader_param("texture_albedo", identity.pattern_eyelids)

		eyelid_left_mat.set_shader_param("albedo_color", identity.color_body_base)
		eyelid_left_mat.set_shader_param("shade_color", identity.color_body_shade)
		eyelid_right_mat.set_shader_param("albedo_color", identity.color_body_base)
		eyelid_right_mat.set_shader_param("shade_color", identity.color_body_shade)

func play_sound_slide(s: bool = false) -> void:
	if s:
		Audio.play_pos_sfx(RegistryAudio.snail_slide_backward, get_global_translation(), Utility.rng.randf_range(1.0, 1.2), 0.4)
	else:
		Audio.play_pos_sfx(RegistryAudio.snail_slide_forward, get_global_translation(), Utility.rng.randf_range(1.2, 1.3), 0.4)

func play_sound_bounce() -> void:
	Audio.play_pos_sfx(RegistryAudio.snail_bounce, get_global_translation(), Utility.rng.randf_range(0.8, 1.2), 0.3)

func play_sound_hide(s: bool = false) -> void:
	if s:
		Audio.play_pos_sfx(RegistryAudio.snail_shell_in, get_global_translation(), Utility.rng.randf_range(0.9, 1.1), 0.7)
	else:
		Audio.play_pos_sfx(RegistryAudio.snail_shell_out, get_global_translation(), Utility.rng.randf_range(0.9, 1.1), 0.7)

func play_sound_peel(s: bool = false) -> void:
	if s:
		Audio.play_pos_sfx(RegistryAudio.snail_peel, get_global_translation(), 1.0, 0.6)
	else:
		Audio.play_pos_sfx(RegistryAudio.snail_peeling, get_global_translation(), Utility.rng.randf_range(0.8, 1.2), 0.5)

func play_sound_slam() -> void:
	Audio.play_pos_sfx(RegistryAudio.snail_slam, get_global_translation(), Utility.rng.randf_range(0.9, 1.1), 0.9)

func play_sound_swipe() -> void:
	var index: int = Utility.rng.randi_range(0, 2)
	var pitch: float = Utility.rng.randf_range(1.0, 1.2)
	match index:
		1:
			Audio.play_pos_sfx(RegistryAudio.needle_swipe_1, get_global_translation(), pitch, 1.5)
		2:
			Audio.play_pos_sfx(RegistryAudio.needle_swipe_2, get_global_translation(), pitch, 1.5)
		_:
			Audio.play_pos_sfx(RegistryAudio.needle_swipe_0, get_global_translation(), pitch, 1.5)

func _on_AffectArea_area_entered(area):
	if area.is_in_group("liquid"):
		submerged = true
		#$MeshInstance.set_visible(true)

func _on_AffectArea_area_exited(area):
	if area.is_in_group("liquid"):
		submerged = false
		#$MeshInstance.set_visible(false)

func _on_AffectArea_body_entered(b):
	if b.is_in_group("damage"):
		set_entity_health(b.get_damage_amount())

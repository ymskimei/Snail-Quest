class_name Player
extends EntityParent

export(Resource) var equipped
export(Resource) var skin

onready var player_cam: SpringArm = GlobalManager.camera
onready var avatar: Spatial = $Armature
onready var skeleton: Skeleton = $"%Skeleton"
onready var states: Node = $StateController
onready var interaction_label: RichTextLabel = $Gui/InteractionLabel
onready var animator: AnimationPlayer = $AnimationPlayer
onready var eye_point: Spatial = $"%EyePoint"
onready var climbing_rays: Spatial = $"%ClimbingRays"
onready var ray_forward: RayCast = $"%RayForward"
onready var danger_area: Area = $DangerArea

onready var is_active_player = false

var cursor = preload("res://source/scenes/gui/gui_aim_cursor.tscn")

var current_collider
var collider

var targeting: bool
var target_found: bool
var enemy_detected: bool

var can_move: bool = true
var can_interact: bool

var in_shell: bool
var is_tool_equipped: bool
var cursor_activated: bool

var interactable = null
var target = null

var cursor_pos: Vector3

var last_vel: Vector3 = Vector3.ZERO

signal health_changed
signal player_killed

func _ready() -> void:
	update_player_appearance()
	states.ready(self)
	set_interaction_text("")
	GlobalManager.register_player(self)
	player_cam.connect("target_updated", self, "_on_cam_target_updated")

func _physics_process(delta: float) -> void:
	states.physics_process(delta)
	if !is_instance_valid(target):
		target = MathHelper.find_target(self, "target")
	else:
		target_check()
	if in_shell:
		eye_point.visible = false
	else:
		eye_point.visible = true

func _integrate_forces(state: PhysicsDirectBodyState) -> void:
	states.integrate_forces(state)
	#rotation.y = lerp_angle(rotation.y, atan2(-last_vel.x, -last_vel.z), 1.0)

func _unhandled_input(event: InputEvent) -> void:
	states.unhandled_input(event)

func _on_cam_target_updated(cam_target) -> void:
	if is_instance_valid(cam_target):
		can_move = true
	else:
		can_move = false

func _on_Area_area_entered(area) -> void:
	if area.is_in_group("danger"):
		inflict_damage(area.get_parent().strength)

func inflict_damage(damage_amount: int) -> void:
	set_current_health(health - damage_amount)
	print("Player Health: " + str(health))

func set_current_health(new_amount: int) -> void:
	health = new_amount
	emit_signal("health_changed", new_amount)
	debug_healthbar()
	if health <= 0:
		kill_player()
		print("Player Died")

func update_equipped_tool() -> void:
	for child in eye_point.get_children():
		eye_point.remove_child(child)
		child.queue_free()
	if equipped.items[0] != null:
		var tool_item = equipped.items[0]
		if tool_item.item_path != "":
			var equipped_tool = load(tool_item.item_path).instance()
			equipped_tool.set_name(tool_item.item_name)
			eye_point.add_child(equipped_tool)

func kill_player() -> void:
	emit_signal("player_killed")

func target_check() -> void:
	var target_distance = target.get_global_translation().distance_to(get_global_translation())
	var relative_facing = target.get_global_transform().basis.z.dot(get_global_transform().origin - target.get_global_transform().origin)
	var max_enemy_distance = 15
	var max_interactable_distance = 5
	if Input.is_action_pressed("cam_lock"):
		targeting = true
		if enemy_detected or ObjectInteractable and target_distance < max_interactable_distance:
			target_found = true
		else:
			target_found = false
	else:
		target = MathHelper.find_target(self, "target")
		targeting = false
	if (target is ObjectInteractable or target.is_in_group("mountable")) and target_distance < max_interactable_distance and relative_facing >= 0:
		can_interact = true
		set_interaction_text(target.get_interaction_text())
		if Input.is_action_just_pressed("action_main"):
			target.interact()
			set_interaction_text("")
	else:
		can_interact = false
		set_interaction_text("")

func _on_DangerArea_body_entered(body) -> void:
	if body is EnemyParent:
		enemy_detected = true

func _on_DangerArea_body_exited(body) -> void:
	if body is EnemyParent:
		enemy_detected = false

func set_interaction_text(text) -> void:
	if !text:
		interaction_label.set_text("")
		interaction_label.set_visible(false)
	else:
		var interaction_key = OS.get_scancode_string(InputMap.get_action_list("action_main")[0].scancode)
		interaction_label.set_text("Press %s to %s" % [interaction_key, text])
		interaction_label.set_visible(true)

#func update_shell_shape(increment) -> void:
#	match int(increment):
#		0:
#			skin.shape_conch = 1.0
#		1:
#			skin.shape_conch = 0.5
#			skin.shape_conical_horizontal = 0.5
#		2:
#			skin.shape_conical_horizontal = 1.0
#		3:
#			skin.shape_conical_horizontal = 0.5
#		5:
#			skin.shape_flat = 0.5
#		6:
#			skin.shape_flat = 1.0
#		7:
#			skin.shape_flat = 0.5
#			skin.shape_conical_vertical = 0.5
#		8:
#			skin.shape_conical_vertical = 1.0

func update_player_appearance() -> void:
	var shell = $"%Shell"
	var body = $"%Body"
	var eye_left = $"%EyeLeft"
	var eye_right = $"%EyeRight"
	
	var shell_mat = shell.get_surface_material(0)
	var shell_accent_mat = shell.get_surface_material(0).get_next_pass()
	var shell_body_mat = shell.get_surface_material(1)
	var body_mat = body.get_surface_material(0)
	var body_accent_mat = body.get_surface_material(0).get_next_pass()
	var eye_left_mat = eye_left.get_surface_material(0).get_next_pass()
	var eye_right_mat = eye_right.get_surface_material(0).get_next_pass()
	
	shell.set_mesh(skin.mesh_shell)
	body.set_mesh(skin.mesh_body)
	eye_left.set_mesh(skin.mesh_eye_left)
	eye_right.set_mesh(skin.mesh_eye_right)
	
	shell_accent_mat.set_shader_param("texture_albedo", skin.pattern_shell)
	body_accent_mat.set_shader_param("texture_albedo", skin.pattern_body)
	eye_left_mat.set_shader_param("texture_albedo", skin.pattern_eyes)
	eye_right_mat.set_shader_param("texture_albedo", skin.pattern_eyes)
	
	shell_mat.set_shader_param("albedo", Color(skin.color_shell_base))
	shell_accent_mat.set_shader_param("albedo", Color(skin.color_shell_accent))
	shell_body_mat.set_shader_param("albedo", Color(skin.color_body))
	body_mat.set_shader_param("albedo", Color(skin.color_body))
	body_accent_mat.set_shader_param("albedo", Color(skin.color_body_accent))
	eye_left_mat.set_shader_param("albedo", Color(skin.color_eye_left))
	eye_right_mat.set_shader_param("albedo", Color(skin.color_eye_right))

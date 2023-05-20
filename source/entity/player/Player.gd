class_name Player
extends EntityParent

export(Resource) var equipped

onready var player_cam = GlobalManager.camera
onready var avatar = $PlayerAvatar
onready var skeleton = $"%Skeleton"
onready var states = $StateController
onready var interaction_label = $Gui/InteractionLabel
onready var animator = $Animation/AnimationPlayer
onready var eye_point = $"%EyePoint"
onready var ray_down = $"%RayDown"
onready var jump_check = $"%CheckerFloor"

var cursor = preload("res://assets/gui/gui_aim_cursor.tscn")

signal health_changed
signal player_killed
signal player_data(position)

var snap_vector = Vector3.ZERO

var current_collider
var collider

var targeting : bool
var target_found : bool
var can_move : bool
var can_interact : bool
var in_shell : bool
var is_tool_equipped : bool
var cursor_activated : bool

var interactable = null
var target = null

var cursor_pos : Vector3

func _ready():
	states.ready(self)
	can_move = true
	set_interaction_text("")
	GlobalManager.register_player(self)

func _physics_process(delta : float) -> void:
	states.physics_process(delta)
	if !is_instance_valid(target):
		target = MathHelper.find_target(self, "target")
	else:
		target_check()
	if in_shell:
		eye_point.visible = false
	else:
		eye_point.visible = true

func _unhandled_input(event: InputEvent) -> void:
	states.unhandled_input(event)

func _on_Area_area_entered(area):
	if area.is_in_group("danger"):
		inflict_damage(area.get_parent().strength)

func inflict_damage(damage_amount):
	set_current_health(health - damage_amount)
	print("Player Health: " + str(health))

func set_current_health(new_amount):
	health = new_amount
	emit_signal("health_changed", new_amount)
	debug_healthbar()
	if health <= 0:
		kill_player()
		print("Player Died")

func update_equipped_tool():
	for child in eye_point.get_children():
		eye_point.remove_child(child)
		child.queue_free()
	if equipped.items[0] != null:
		var tool_item = equipped.items[0]
		if tool_item.item_path != "":
			var equipped_tool = load(tool_item.item_path).instance()
			equipped_tool.set_name(tool_item.item_name)
			eye_point.add_child(equipped_tool)

func kill_player():
	emit_signal("player_killed")

func target_check():
	var target_distance = target.get_global_translation().distance_to(get_global_translation())
	var relative_facing = target.get_global_transform().basis.z.dot(get_global_transform().origin - target.get_global_transform().origin)
	var max_enemy_distance = 15
	var max_interactable_distance = 2
	if Input.is_action_pressed("cam_lock"):
		targeting = true
		if target is EnemyParent and target_distance < max_enemy_distance or ObjectInteractable and target_distance < max_interactable_distance:
			target_found = true
		else:
			target_found = false
	else:
		target = MathHelper.find_target(self, "target")
		targeting = false
		
	if target is ObjectInteractable and target_distance < max_interactable_distance and relative_facing >= 0:
		can_interact = true
		set_interaction_text(target.get_interaction_text())
		if Input.is_action_just_pressed("action_main"):
			target.interact()
			set_interaction_text("")
	else:
		can_interact = false
		set_interaction_text("")

func set_interaction_text(text):
	if !text:
		interaction_label.set_text("")
		interaction_label.set_visible(false)
	else:
		var interaction_key = OS.get_scancode_string(InputMap.get_action_list("action_main")[0].scancode)
		interaction_label.set_text("Press %s to %s" % [interaction_key, text])
		interaction_label.set_visible(true)

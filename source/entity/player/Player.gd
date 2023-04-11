class_name Player
extends EntityParent

onready var player_cam = get_parent().get_node("Camera")
onready var avatar = $PlayerAvatar
onready var skeleton = $"%Skeleton"
onready var states = $StateController
onready var interaction_label = $Gui/InteractionLabel
onready var animator = $Animation/AnimationPlayer

onready var ray_down = $"%RayDown"
onready var jump_check = $"%CheckerFloor"

signal health_changed
signal player_killed
signal player_data(position)

var snap_vector = Vector3.ZERO

var current_collider
var collider

var targeting : bool
var can_move : bool
var can_interact : bool

var interactable = null
var target

func _ready():
	states.ready(self)
	can_move = true
	set_interaction_text("")
	GlobalManager.register_player(self)

func _physics_process(delta : float) -> void:
	states.physics_process(delta)
	if is_instance_valid(target):
		target_check()
	else:
		target = MathHelper.find_target(self, "target")

func _unhandled_input(event: InputEvent) -> void:
	states.unhandled_input(event)

func _on_body_entered(body):
	if body.is_in_group("enemy"):
		inflict_damage(body.strength)

func inflict_damage(damage_amount):
	set_current_health(health - damage_amount)
	print("Player Health: " + str(health))

func set_current_health(new_amount):
	health = new_amount
	emit_signal("health_changed", new_amount)
	if health <= 0:
		kill_player()
		print("Player Died")

func kill_player():
	emit_signal("player_killed")

func target_check():
	var target_distance = target.get_global_translation().distance_to(get_global_translation())
	var relative_facing = target.get_global_transform().basis.z.dot(get_global_transform().origin - target.get_global_transform().origin)
	var max_enemy_distance = 15
	var max_interactable_distance = 2
	if Input.is_action_pressed("cam_lock"):
		if target is EnemyParent and target_distance < max_enemy_distance or ObjectInteractable and target_distance < max_interactable_distance:
			targeting = true
		else:
			targeting = false
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



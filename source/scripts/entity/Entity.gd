class_name Entity
extends RigidBody

export(Resource) var resource
export(Resource) var equipped

onready var cam: SpringArm = GlobalManager.camera

onready var controllable = false
onready var states: Node = $StateController
onready var skeleton: Skeleton = $Armature/Skeleton
onready var attach_point: Spatial = $"%EyePoint"
onready var animator: AnimationPlayer = $AnimationPlayer
onready var proximity: Area = $Proximity

onready var interaction_label: RichTextLabel = $Gui/InteractionLabel

onready var entity_name: String
onready var health: int
onready var max_health: int
onready var strength: int
onready var gravity: int
onready var speed: int
onready var acceleration: int
onready var jump: int

var velocity: Vector3 = Vector3.ZERO
var direction: Vector3 = Vector3.ZERO
var input: Vector3 = Vector3.ZERO

var interactable = null
var target = null

var can_move: bool = true
var can_interact: bool
var targeting: bool
var target_found: bool
var enemy_detected: bool

signal health_changed
signal entity_killed

func _ready() -> void:
	entity_name = resource.entity_name
	health = resource.health
	max_health = resource.max_health
	strength = resource.strength
	gravity = resource.gravity
	speed = resource.speed
	acceleration = resource.acceleration
	jump = resource.jump
	if is_instance_valid(proximity):
		proximity.connect("area_entered", self, "_on_proximity_entered")
		proximity.connect("area_exited", self, "_on_proximity_exited")
	display_debug_healthbar()
	cam.connect("target_updated", self, "_on_cam_target_updated")

func _unhandled_input(event: InputEvent) -> void:
	pass

func _physics_process(delta: float) -> void:
	if !is_instance_valid(target):
		target = MathHelper.find_target(self, "target")
	else:
		target_check()

func _integrate_forces(state: PhysicsDirectBodyState) -> void:
	pass

func _on_cam_target_updated(cam_target) -> void:
	if is_instance_valid(cam_target):
		can_move = true
	else:
		can_move = false

func set_entity_health(new_amount: int) -> void:
	health = new_amount
	emit_signal("health_changed", new_amount)
	display_debug_healthbar()
	if health <= 0:
		kill_entity()
		print(str(self.name) +" Died")

func _on_proximity_entered(body) -> void:
	pass

func _on_proximity_exited(body) -> void:
	pass

func damage_entity(damage_amount: int) -> void:
	set_entity_health(health - damage_amount)
	print(str(self.name) +" Health: " + str(health))

func kill_entity() -> void:
	emit_signal("entity_killed")

func display_debug_healthbar() -> void:
	if is_instance_valid($DebugHealthBar):
		$DebugHealthBar.update_bar(health)
		if is_instance_valid($"%Body"):
			$DebugHealthBar.translation.y = $"%Body".get_aabb().size.y + 1

func update_equipped() -> void:
	for child in attach_point.get_children():
		attach_point.remove_child(child)
		child.queue_free()
	if equipped.items[0] != null:
		var tool_item = equipped.items[0]
		if tool_item.item_path != "":
			var equipped_tool = load(tool_item.item_path).instance()
			equipped_tool.set_name(tool_item.item_name)
			attach_point.add_child(equipped_tool)

func get_coords() -> Vector3:
	var x = round(global_transform.origin.x)
	var y = round(global_transform.origin.y)
	var z = round(global_transform.origin.z)
	var coords = [x, y, z]
	return coords

func set_coords(position: Vector3, angle: String) -> void:
	set_global_translation(position)
	set_global_rotation(Vector3(0, deg2rad(MathHelper.cardinal_to_degrees(angle)), 0))

func set_interaction_text(text) -> void:
	if !text:
		interaction_label.set_text("")
		interaction_label.set_visible(false)
	else:
		var interaction_key = OS.get_scancode_string(InputMap.get_action_list("action_main")[0].scancode)
		interaction_label.set_text("Press %s to %s" % [interaction_key, text])
		interaction_label.set_visible(true)

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

#func strike_flash(ar: Spatial) -> void:
#	var flash = OmniLight.new()
#	var tween = Tween.new()
#	flash.omni_range = 10
#	flash.omni_attenuation = 0
#	flash.light_color = Color("00C3FF")
#	flash.light_energy = 1
#	flash.light_specular = 1
#	flash.shadow_enabled = true
#	flash.shadow_bias = 2.5
#	flash.translation = ar.translation
#	add_child(flash)
#	add_child(tween)
#	tween.interpolate_property(flash, "light_color", flash.light_color, Color("000000"), 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
#	tween.start()
#	yield(tween, "tween_completed")
#	flash.queue_free()
#	tween.queue_free()

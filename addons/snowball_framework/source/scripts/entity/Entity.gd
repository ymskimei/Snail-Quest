class_name Entity
extends Conversable

export var identity: Resource = null
export var inventory: Resource = null

onready var states: Node = $StateController
onready var skeleton: Skeleton = $Armature/Skeleton
onready var mesh: MeshInstance = $"%MeshInstance"
onready var anim: AnimationPlayer = $AnimationPlayer

var entity_name: String
var health: int
var max_health: int
var strength: int
var speed: int
var jump: int

var target = null

var can_interact: bool = false
var interacting: bool = false
var can_target: bool = false
var targeting: bool = false
var target_found: bool = false
var enemy_found: bool = false
var jump_in_memory: bool = false
var ledge_usable: bool = true
var pushing: bool = false
var attached_to_location: bool
var immortal: bool = false

var max_enemy_distance: int = 15
var max_interactable_distance: int = 3

var jump_memory_timer: Timer = Timer.new()
var ledge_timer: Timer = Timer.new()

signal health_changed(health, max_health, b)
signal entity_killed(b)

func _ready() -> void:
	_set_identity()
	_set_display_health()
	_get_timers()
	#temp until can be updated from outside
	SB.camera.connect("target_updated", self, "_on_cam_target_updated")
	emit_signal("health_changed", health, max_health, is_controlled())

func _unhandled_input(event: InputEvent) -> void:
	if is_controlled():
		var b = Device.trigger_left
		if event.is_action_pressed(b):
			if is_instance_valid(target):
				can_target = true
		elif event.is_action_released(b):
			if is_instance_valid(target):
				can_target = false
		if is_instance_valid(target):
			if event.is_action_pressed(Device.action_main):
				target_interact()
		if SB.game.interface.options.debug_mode:
			if event.is_action_pressed("debug_cam_fov_decrease"):
				set_entity_health(1)
			if event.is_action_pressed("debug_cam_fov_increase"):
				set_entity_health(-1)

func _process(delta: float) -> void:
	if is_controlled():
		if is_instance_valid(target):
			target_check()
		else:
			target = Utility.find_target(self, "target")

func _set_identity() -> void:
	if identity:
		entity_name = identity.entity_name
		character = identity.character
		health = identity.health
		max_health = identity.max_health
		strength = identity.strength
		speed = identity.speed
		jump = identity.jump

func _get_timers():
	jump_memory_timer.set_wait_time(0.075)
	jump_memory_timer.one_shot = true
	jump_memory_timer.connect("timeout", self, "on_jump_memory_timeout")
	add_child(jump_memory_timer)
	ledge_timer.set_wait_time(1)
	ledge_timer.one_shot = true
	ledge_timer.connect("timeout", self, "on_ledge_timeout")
	add_child(ledge_timer)

func set_entity_health(new_amount: int) -> void:
	if !immortal:
		health += new_amount
		if health > max_health:
			health = max_health
		elif health <= 0:
			health = 0
			kill_entity()
			print(str(self.name) +" Died")
		emit_signal("health_changed", health, max_health, is_controlled())
		_set_display_health()
		#print(str(self.name) +" Health: " + str(health))

func set_entity_max_health(new_amount: int) -> void:
	max_health += new_amount
	health = max_health
	emit_signal("health_changed", health, max_health, is_controlled())
	_set_display_health()
	#print(str(self.name) +" Health: " + str(health))

func _set_display_health() -> void:
	if is_instance_valid($DebugHealthBar):
		$DebugHealthBar.update_bar(mesh, health, max_health)

func kill_entity() -> void:
	emit_signal("entity_killed", is_controlled())
	#do death stuff here

func update_equipped(point) -> void:
	for child in point.get_children():
		point.remove_child(child)
		child.queue_free()
	if inventory.items[0] != null:
		var tool_item = inventory.items[0]
		if tool_item.item_path != "":
			var equipped_tool = load(tool_item.item_path).instance()
			equipped_tool.set_name(tool_item.item_name)
			point.add_child(equipped_tool)

func target_check() -> void:
	var target_distance = target.get_global_translation().distance_to(get_global_translation())
	if can_target:
		if enemy_found or (!target.is_controlled() and target_distance < max_interactable_distance):
			target_found = true
		else:
			target_found = false
	else:
		target = Utility.find_target(self, "target")

func target_interact() -> void:
	var target_distance: float  = target.get_global_translation().distance_to(get_global_translation())
	var relative_facing: float = target.get_global_transform().basis.z.dot(get_global_transform().origin - target.get_global_transform().origin)
	if (!target.is_controlled() and target is Interactable) and (target_distance < max_interactable_distance and relative_facing >= 0):
		can_interact = true
		set_interaction_text(target.get_interaction_text())
		if target.is_in_group("pushable"):
			pushing = true
		interacting = true
		target.interact()
		set_interaction_text("")
		yield(target, "interaction_ended")
		interacting = false
	else:
		pushing = false
		can_interact = false
		set_interaction_text("")

func set_interaction_text(text) -> void:
	var label = SB.game.interface.hud.interaction_label
	if !text:
		label.set_text("")
		label.set_visible(false)
	else:
		var interaction_key = OS.get_scancode_string(InputMap.get_action_list(Device.action_main)[0].scancode)
		label.set_text("Press %s to %s" % [interaction_key, text])
		label.set_visible(true)

func get_interaction_text():
	return "chat"

func interact():
	trigger_dialog()

func _on_Area_area_entered(area) -> void:
	if area.is_in_group("danger"):
		set_entity_health(-(area.get_parent().strength))
	if area.is_in_group("attachable"):
		_set_attached(area.get_parent().get_parent().get_parent())

func _set_attached(node: Interactable) -> void:
	SB.set_prev_controlled(self)
	SB.set_controlled(node)
	attached_to_location = true

func jump_memory() -> void:
	jump_in_memory = true
	jump_memory_timer.start()

func on_jump_memory_timeout() -> void:
	jump_in_memory = false

func ledge() -> void:
	ledge_usable = false
	ledge_timer.start()

func on_ledge_timeout() -> void:
	ledge_usable = true

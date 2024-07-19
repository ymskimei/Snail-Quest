class_name Entity
extends Conversable

export var identity: Resource

onready var states: Node = $StateController
onready var skeleton: Skeleton = $Armature/Skeleton
onready var collision: CollisionShape = $CollisionShape
onready var mesh: MeshInstance = $"%MeshInstance"
onready var surface_rays: Spatial = $SurfaceRays
onready var listener: Listener = $Listener

export var health: int = 10
export var max_health: int = 10
export var currency: int = 0
export var keys: int = 0
export var boss_key: bool = false
export var items: Array = []
export var strength: int = 1
export var speed: int = 10
export var jump: int = 65

var direction: Vector3 = Vector3.ZERO

var fall_momentum: float = 0.0
var move_momentum: float = 0.0
var max_momentum: float = 0.5
var boost_momentum: Vector3 = Vector3.ZERO

var facing: float = 0.0

var target = null
var can_swap_target: bool = true
var all_targets = []
var enemy_found: bool = false

var can_interact: bool = false
var interacting: bool = false
var targeting: bool = false
var jump_in_memory: bool = false
var can_late_jump: bool = false
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

signal target_updated()

func _ready() -> void:
	_set_display_health()
	_get_timers()
	#temp until can be updated from outside

	SnailQuest.camera.connect("target_updated", self, "_on_cam_target_updated")
	emit_signal("health_changed", health, max_health, can_be_controlled())

func _unhandled_input(event: InputEvent) -> void:
	if can_be_controlled():
		if !SnailQuest.camera.looking:
			if event.is_action_pressed(Device.trigger_left):
				targeting = true
				if all_targets.size() > 0:
					target = all_targets[0]
			elif event.is_action_released(Device.trigger_left):
				targeting = false
				target = null

		if targeting and target and can_swap_target:
			var input = Vector2.ZERO
			input.x = event.get_action_strength(Device.stick_alt_left) - event.get_action_strength(Device.stick_alt_right)
			input.y = event.get_action_strength(Device.stick_alt_up) - event.get_action_strength(Device.stick_alt_down)

			if event.is_action_pressed(Device.stick_alt_left) or event.is_action_pressed(Device.stick_alt_right)or event.is_action_pressed(Device.stick_alt_up) or event.is_action_pressed(Device.stick_alt_down):
				var next_target = _get_viewport_target(input.normalized())
				if next_target:
					can_swap_target = false
					target = next_target
					yield(get_tree().create_timer(0.3), "timeout")
					can_swap_target = true

		if target:
			if event.is_action_pressed(Device.action_main):
				target_interact()

		if Interface.options.debug_mode:
			if event.is_action_pressed(Device.debug_fov_decrease):
				set_entity_health(1)
			if event.is_action_pressed(Device.debug_fov_increase):
				set_entity_health(-1)

func _get_viewport_target(dir):
	var nearest_target = null
	var nearest_distance = INF
	for t in all_targets:
		if t != target and global_transform.origin.distance_to(t.global_transform.origin) < 10:
			var vec3_target_direction = (t.global_transform.origin - global_transform.origin).rotated(Vector3.UP, SnailQuest.camera.rotation.y)
			var target_direction = Vector2(vec3_target_direction.x, vec3_target_direction.y)
			#var target_direction = (SnailQuest.camera.lens.unproject_position(t.global_transform.origin) - SnailQuest.camera.lens.unproject_position(target.global_transform.origin))
			var dot_result = dir.normalized().dot(target_direction.normalized())
			if target_direction.length() < nearest_distance and dot_result:
				nearest_target = t
	return nearest_target

func _physics_process(delta: float) -> void:
	if can_be_controlled():
		all_targets = Utility.get_group_by_nearest(self, "target")
		if targeting and target:
			if !global_transform.origin.distance_to(target.global_transform.origin) < 10:
				target = null

func can_be_controlled() -> bool:
	if SnailQuest.get_is_network_active():
		if is_network_master():
			return true
	elif is_controlled():
		return true
	return false

func _get_timers():
	jump_memory_timer.set_wait_time(0.075)
	jump_memory_timer.one_shot = true
	jump_memory_timer.connect("timeout", self, "on_jump_memory_timeout")
	add_child(jump_memory_timer)
	ledge_timer.set_wait_time(1)
	ledge_timer.one_shot = true
	ledge_timer.connect("timeout", self, "on_ledge_timeout")
	add_child(ledge_timer)

func set_entity_identity(appearance: Resource) -> void:
	identity = appearance

func get_entity_identity() -> Resource:
	return identity

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

func set_entity_max_health(new_amount: int) -> void:
	max_health += new_amount
	health = max_health

	emit_signal("health_changed", health, max_health, is_controlled())
	_set_display_health()

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

	if identity.items[0] != null:
		var tool_item = identity.items[0]

		if tool_item.item_path != "":
			var equipped_tool = load(tool_item.item_path).instance()
			equipped_tool.set_name(tool_item.item_name)
			point.add_child(equipped_tool)

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
	var label = Interface.hud.interaction_label
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
	#trigger_dialog()
	pass

func _on_Area_area_entered(area) -> void:
	if area.is_in_group("danger"):
		set_entity_health(-(area.get_parent().strength))

	if area.is_in_group("attachable"):
		_set_attached(area.get_parent().get_parent().get_parent())

func _set_attached(node: Interactable) -> void:
	SnailQuest.set_prev_controlled(self)
	SnailQuest.set_controlled(node)
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

func set_max_health(amount: int) -> void:
	max_health = amount

func get_max_health() -> int:
	return max_health

func set_health(amount: int) -> void:
	health = amount

func get_health() -> int:
	return health

func set_currency(amount: int) -> void:
	currency = amount

func get_currency() -> int:
	return currency

func set_keys(amount: int) -> void:
	keys = amount

func get_keys() -> int:
	return keys

func set_boss_key(has: bool) -> void:
	boss_key = has

func get_boss_key() -> bool:
	return boss_key

func set_items(inventory: Array) -> void:
	items = inventory

func get_items() -> Array:
	return items

func set_strength(power: int) -> void:
	strength = power

func get_strength() -> int:
	return strength

func set_speed(power: int) -> void:
	speed = power

func get_speed() -> int:
	return speed

func set_jump(power: int) -> void:
	jump = power

func get_jump() -> int:
	return jump

func _on_Network_tick_rate_timeout() -> void:
	if is_network_master():
		pass

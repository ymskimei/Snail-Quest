class_name Entity
extends Conversable

onready var states: Node = $StateController
onready var skeleton: Skeleton = $Armature/Skeleton
onready var collision: CollisionShape = $CollisionShape
onready var surface_rays: Spatial = $SurfaceRays

onready var listener: Listener = $Listener

onready var proximity: Area

## Data ##

export var identity: Resource

export var health: int = 10
export var max_health: int = 10
export var currency: int = 0
export var keys: int = 0
export var boss_key: bool = false
export var items: Array = []
export var strength: int = 1

## Physics ##

export var speed: int = 10
export var jump: int = 65

var direction: Vector3 = Vector3.ZERO
var facing: float = 0.0

var fall_momentum: float = 0.0
var move_momentum: float = 0.0
var max_momentum: float = 0.5
var boost_momentum: Vector3 = Vector3.ZERO

## Eyes ##

var freelooking: bool = true

var eyesight: Camera
var relevent_goal: Interactable
var looking_target: Interactable

var blink_timer: Timer
var blink_end_timer: Timer

export var blink_texture: Texture
export var wince_texture: Texture
export var tired_texture: Texture
export var sleepy_eye_texture: Texture
export var happy_eye_texture: Texture
export var angry_eye_texture: Texture
export var sad_eye_texture: Texture

## Misc ##

var targets_list = []

var target = null
var can_swap_target: bool = true
var all_targets = []
var enemy_found: bool = false
var submerged: bool = false

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

	proximity = Area.new()
	add_child(proximity)
	proximity.add_child(CollisionShape.new())
	proximity.get_child(0).set_shape(SphereShape.new())
	proximity.set_scale(Vector3(15.0, 15.0, 15.0))
	proximity.connect("body_entered", self, "_on_Proximity_entered")
	proximity.connect("body_exited", self, "_on_Proximity_exited")

	eyesight = Camera.new()
	eyesight.set_zfar(false)
	eyesight.set_affect_lod(false)
	add_child(eyesight)

	SnailQuest.camera.connect("target_updated", self, "_on_cam_target_updated")
	emit_signal("health_changed", health, max_health, is_controlled())

func _unhandled_input(event: InputEvent) -> void:
	if is_controlled():
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
	if is_controlled():
		all_targets = Utility.get_group_by_nearest(self, "target")
		if targeting and target:
			if !global_transform.origin.distance_to(target.global_transform.origin) < 10:
				target = null

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

## Eye behavior ##

func set_looking_target() -> void:
	#looking_target = SnailQuest.get_controlled()
	if relevent_goal and relevent_goal.get_global_translation().distance_to(get_global_translation()) > 15:
		looking_target = relevent_goal
	elif is_controlled():
		if targets_list.size() > 0:
			var closest_target: Interactable
			var min_distance: float = INF
			for t in targets_list:
				if is_instance_valid(t):
					var distance = t.get_global_translation().distance_to(get_global_translation())
					if distance < min_distance and distance < 10.0:
						min_distance = distance
						closest_target = t
			looking_target = closest_target
	else:
		if SnailQuest.get_controlled().get_global_translation().distance_to(get_global_translation()) > 10:
			looking_target = SnailQuest.get_controlled()
		elif targets_list.size() > 0:
			var closest_target: Conversable
			var min_distance: float = INF
			for t in targets_list:
				if is_instance_valid(t):
					if t is Conversable:
						var distance = t.get_global_translation().distance_to(get_global_translation())
						if distance < min_distance and distance < 7.0:
							min_distance = distance
							closest_target = t
			looking_target = closest_target

func eye_tracking_behavior(delta: float, eye_mat_left: Material, eye_mat_right: Material) -> void:
	if freelooking and looking_target:
		var previous_looking_direction = eye_mat_left.get_next_pass().get_shader_param("pupil_position")

		var looking_target_direction = looking_target.get_global_translation() - get_global_translation()
		looking_target_direction = looking_target_direction.rotated(Vector3.UP, -get_global_rotation().y)
	
		var looking_direction: Vector2 = Vector2(looking_target_direction.x, looking_target_direction.y)
		looking_direction = looking_direction.normalized()
		
		var looking_direction_adjusted: Vector2	 = Vector2(
			Utility.adjusted_range(looking_direction.x, -1.0, 1.0, -0.4, 0.4),
			Utility.adjusted_range(looking_direction.y, -1.0, 1.0, -0.4, 0.4))
	
		eye_mat_left.get_next_pass().set_shader_param("pupil_position", lerp(previous_looking_direction, looking_direction_adjusted, 10 * delta))
		eye_mat_right.get_next_pass().set_shader_param("pupil_position", lerp(previous_looking_direction, looking_direction_adjusted, 10 * delta))
		$MeshInstance.set_global_translation(Vector3.UP * 2 + looking_target.get_global_translation())
	else:
		eye_mat_left.get_next_pass().set_shader_param("pupil_position", Vector2(0, 0))
		eye_mat_right.get_next_pass().set_shader_param("pupil_position", Vector2(0, 0))

func eye_blinking_init(eye_mat_left: Material, eye_mat_right: Material) -> void:
	blink_timer = Timer.new()
	blink_end_timer = Timer.new()
	blink_timer.set_wait_time(0.1)
	blink_timer.connect("timeout", self, "_on_blink_timeout", [eye_mat_left.get_next_pass().get_next_pass(), eye_mat_right.get_next_pass().get_next_pass()])
	blink_end_timer.connect("timeout", self, "_on_blink_end_timeout", [eye_mat_left.get_next_pass().get_next_pass(), eye_mat_right.get_next_pass().get_next_pass()])
	add_child(blink_timer)
	add_child(blink_end_timer)
	blink_timer.start()

func _on_blink_timeout(eyelid_left: Material, eyelid_right: Material) -> void:
	var blink_length: float = 0.25
	blink_timer.set_wait_time(Utility.rng.randf_range(4.0, 12.0))
	if randi() % 64 == 1:
		blink_length += Utility.rng.randf_range(1.0, 6.0)
		eyelid_left.set_shader_param("texture_albedo", wince_texture)
		eyelid_right.set_shader_param("texture_albedo", wince_texture)
	else:
		eyelid_left.set_shader_param("texture_albedo", blink_texture)
		eyelid_right.set_shader_param("texture_albedo", blink_texture)
	blink_end_timer.set_wait_time(blink_length)
	blink_end_timer.start()

	if randi() % 2 == 1:
		freelooking = true
	else:
		freelooking = false

func _on_blink_end_timeout(eyelid_left: Material, eyelid_right: Material):
	if EnvironmentMaster.time > EnvironmentMaster.time_twili or EnvironmentMaster.time < EnvironmentMaster.time_dawn:
		eyelid_left.set_shader_param("texture_albedo", tired_texture)
		eyelid_right.set_shader_param("texture_albedo", tired_texture)
	else:
		eyelid_left.set_shader_param("texture_albedo", identity.get_pattern_eyelids())
		eyelid_right.set_shader_param("texture_albedo", identity.get_pattern_eyelids())

## Targeting behavior ##

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

func _on_Proximity_entered(body) -> void:
	if body is Interactable and body != self:
		targets_list.append(body)
	
func _on_Proximity_exited(body) -> void:
	if body is Interactable and body != self:
		for t in targets_list.size() - 1:
			if targets_list[t] == body:
				targets_list.remove(t)

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

func has_boss_key() -> bool:
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

func is_submerged() -> bool:
	return submerged

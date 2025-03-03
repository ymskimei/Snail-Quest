class_name Entity
extends Conversable

export var fake_body: PackedScene

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

var location: String = "Snaily Town"
var mood_level: int = 5

## Physics ##

export var jump: int = 65

var gravity: float = 9.8
var surface_normal: Vector3
var distanced_normal: Vector3

var raw_facing_angle: float
var facing_direction: Vector3
var move_direction: Vector3
var boost_direction: Vector3
var jump_strength: float

var fall_momentum: float = 0.0
var move_momentum: float = 0.0
var max_momentum: float = 0.4

var zero_gravity: bool = false
var zero_movement: bool = false
var mirrored_movement: bool = false
var on_surface: bool = false

## Eyes ##

var freelooking: bool = true
var random_looking_direction: Vector2

var eyesight: Camera
var relevent_goal: Interactable
var looking_target: PhysicsBody

var blink_timer: Timer
var blink_end_timer: Timer

export var blink_texture: Texture
export var wince_texture: Texture
export var tired_texture: Texture
export var sleepy_eye_texture: Texture
export var happy_eye_texture: Texture
export var angry_eye_texture: Texture
export var sad_eye_texture: Texture

## Inputs ##

var modified_input_direction: Vector3
var input_direction: Vector2

var boosting: bool = false
var can_jump: bool = false
var can_turn: bool = true
var can_roll: bool = true

## Behavior ##

export var speed: float = 1
var speed_modifier: float = 1.0
var auto_navigation: bool = false
var navigation_destination: Vector3

var navigation_agent: NavigationAgent

## Misc ##

var proximity_list = []

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
var pushing: bool = false
var attached_to_location: bool
var immortal: bool = false

var jump_memory_timer: Timer = Timer.new()
var navigation_decision_timer: Timer = Timer.new()

signal health_changed(health, max_health, b)
signal entity_killed(b)

signal target_updated()

func _ready() -> void:
	gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

	jump_memory_timer.set_wait_time(0.075)
	jump_memory_timer.one_shot = true
	jump_memory_timer.connect("timeout", self, "_on_jump_memory_timeout")
	add_child(jump_memory_timer)

	navigation_decision_timer.set_wait_time(0.1)
	navigation_decision_timer.one_shot = true
	navigation_decision_timer.connect("timeout", self, "_on_navigation_decision_timeout")
	add_child(navigation_decision_timer)
	navigation_decision_timer.start()

	eyesight = Camera.new()
	eyesight.set_zfar(false)
	eyesight.set_affect_lod(false)
	add_child(eyesight)

	proximity = Area.new()
	add_child(proximity)

	proximity.add_child(CollisionShape.new())
	proximity.get_child(0).set_shape(SphereShape.new())
	if is_controlled():
		proximity.set_scale(Vector3(16.0, 16.0, 16.0))
	else:
		proximity.set_scale(Vector3(8.0, 8.0, 8.0))
	proximity.connect("body_entered", self, "_on_Proximity_entered")
	proximity.connect("body_exited", self, "_on_Proximity_exited")

	navigation_agent = NavigationAgent.new()
	add_child(navigation_agent)

	_set_display_health()
	emit_signal("health_changed", health, max_health, is_controlled())

	SnailQuest.camera.connect("target_updated", self, "_on_cam_target_updated")

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

		if event.is_action_pressed(Device.action_main) and can_interact and !interacting:
			target.interact()

		if Interface.options.debug_mode:
			if event.is_action_pressed(Device.debug_fov_decrease):
				set_entity_health(1)
			if event.is_action_pressed(Device.debug_fov_increase):
				set_entity_health(-1)

func _physics_process(delta: float) -> void:
	## Surface Normal ##

	var norm_avg: Vector3 = Vector3.ZERO
	var sticky_rays_colliding: int = 0
	var distanced_norm_avg: Vector3 = Vector3.ZERO
	var distanced_rays_colliding: int = 0
	
	for ray in surface_rays.get_children():
		var r : RayCast = ray
		if r.is_colliding():
			distanced_rays_colliding += 1
			distanced_norm_avg += r.get_collision_normal()

			if get_global_translation().distance_to(r.get_collision_point()) < 0.5:
				if r.get_collider().is_in_group("sticky"):
					sticky_rays_colliding += 1
					norm_avg += r.get_collision_normal()

	if norm_avg:
		distanced_normal = distanced_norm_avg / distanced_rays_colliding
		surface_normal = norm_avg / sticky_rays_colliding
	else:
		distanced_normal = Vector3.ZERO
		surface_normal = Vector3.UP

	## Gravity and Movement ##

	var modified_gravity: Vector3 = Vector3.ZERO
	var modified_movement: Vector3 = Vector3.ZERO

	if !zero_gravity and !is_on_floor():
		modified_gravity = -surface_normal * (1.0 + fall_momentum) * gravity * 0.6

		if is_submerged():
			modified_gravity = modified_gravity * 0.5

	if !zero_movement:
		modified_movement = move_direction + (surface_normal * jump_strength)

	var movement_vector: Vector3
	if interacting:
		movement_vector = Vector3.ZERO
	else:
		movement_vector = modified_gravity + modified_movement + boost_direction
		raw_facing_angle = get_global_rotation().y
		set_global_rotation(Utility.align_from_rotation(delta, get_global_rotation(), surface_normal, facing_direction, 16 * delta))
	move_and_slide_with_snap(movement_vector, surface_normal, Vector3.UP, true, 4, deg2rad(90), false)

	if !is_controlled():
		_auto_navigate()

	## Target Search ##

	if is_controlled():
		_update_nearest_target()

## Behavioral AI ##

func _on_navigation_decision_timeout() -> void:
	if randi() % 3:
		auto_navigation = true
		#if randi() % 2:
		navigation_destination = get_global_translation() + Vector3(Utility.rng.randi_range(-10, 10), 0, Utility.rng.randi_range(-10, 10))
		speed_modifier = Utility.rng.randf_range(0.05, 0.2)
	else:
		auto_navigation = false
		input_direction = Vector2.ZERO

	navigation_decision_timer.set_wait_time(Utility.rng.randf_range(3, 10))
	navigation_decision_timer.start()

func _auto_navigate() -> void:
	if is_instance_valid(SnailQuest.get_controlled()):
		if proximity_list.size() > 0 and get_global_translation().distance_to(SnailQuest.get_controlled().get_global_translation()) > 1.5:
			if !interacted_with and auto_navigation:
				navigation_agent.set_target_location((navigation_destination - get_global_translation()).normalized())
				input_direction = Vector2(navigation_agent.get_next_location().x - get_global_translation().x, navigation_agent.get_next_location().z - get_global_translation().z) * speed_modifier * speed

	#			var navigation_direction: Vector3 = (navigation_destination - get_global_translation()).normalized()
	#			input_direction = Vector2(navigation_direction.x, navigation_direction.z) * speed_modifier * speed

	else:
		input_direction = Vector2.ZERO
		#Input.action_press("action_main")

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
	if interacted_with:
		looking_target = SnailQuest.get_controlled()
	else:
		if relevent_goal and relevent_goal.get_global_translation().distance_to(get_global_translation()) > 15:
			looking_target = relevent_goal

		elif is_controlled():
			if proximity_list.size() > 0:
				var closest_target: Interactable
				var min_distance: float = INF

				for t in proximity_list:
					if is_instance_valid(t):
						var distance = t.get_global_translation().distance_to(get_global_translation())
						if distance < min_distance and distance < 10.0:
							min_distance = distance
							closest_target = t
				looking_target = closest_target

		else:
			if is_instance_valid(SnailQuest.get_controlled()):
				if SnailQuest.get_controlled().get_global_translation().distance_to(get_global_translation()) > 10:
					looking_target = SnailQuest.get_controlled()

			elif proximity_list.size() > 0:
				var closest_target: Conversable
				var min_distance: float = INF

				for t in proximity_list:
					if is_instance_valid(t):
						if t is Conversable:
							var distance = t.get_global_translation().distance_to(get_global_translation())

							if distance < min_distance and distance < 7.0:
								min_distance = distance
								closest_target = t
				looking_target = closest_target

func eye_tracking_behavior(delta: float, eye_mat_left: Material, eye_mat_right: Material) -> void:
	if freelooking and is_instance_valid(looking_target):
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
	else:
		eye_mat_left.get_next_pass().set_shader_param("pupil_position", random_looking_direction)
		eye_mat_right.get_next_pass().set_shader_param("pupil_position", random_looking_direction)

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

	if randi() % 4 == 1:
		freelooking = false
	else:
		random_looking_direction = Vector2(Utility.rng.randf_range(-0.4, 0.4), Utility.rng.randf_range(-0.4, 0.4))
		freelooking = true

func _on_blink_end_timeout(eyelid_left: Material, eyelid_right: Material):
	if _get_time_cycle() == "MC" or _get_time_cycle() == "NC" or _get_time_cycle() == "MS" or _get_time_cycle() == "NS":
		eyelid_left.set_shader_param("texture_albedo", tired_texture)
		eyelid_right.set_shader_param("texture_albedo", tired_texture)

	else:
		eyelid_left.set_shader_param("texture_albedo", identity.get_pattern_eyelids())
		eyelid_right.set_shader_param("texture_albedo", identity.get_pattern_eyelids())

## Targeting behavior ##

func _update_nearest_target() -> void:
	var closest_distance = INF
	for t in proximity_list:
		if t.is_in_group("target"):
			var distance = t.get_global_translation().distance_to(get_global_translation())
			if distance < closest_distance:
				closest_distance = distance
				target = t

	if target != null:
		var target_distance: float = target.get_global_translation().distance_to(get_global_translation())
		var relative_facing: float = target.get_global_transform().basis.z.dot(get_global_transform().origin - target.get_global_transform().origin)

		if (!target.is_controlled() and target is Interactable) and target_distance < 1.5: #and relative_facing >= 0):
			can_interact = true
		else:
			if interacting:
				interacting = false
			can_interact = false
	
		if can_interact and !interacting:
			set_interaction_text(target.get_interaction_text())
		else:
			set_interaction_text("")

func interact() -> void:
	var bubble: CanvasLayer = dialog_bubble.instance()
	bubble.dialog_display_name = get_entity_identity().get_entity_name()
	bubble.current_dialog_keys = dialog_fetcher()
	camera_override()
	if bubble.current_dialog_keys.size() > 0:
		add_child(bubble)
		bubble.connect("dialog_ended", self,"_dialog_end")
		interacted_with = true
		facing_direction = (facing_direction - SnailQuest.get_controlled().facing_direction).normalized()
		SnailQuest.get_controlled().interacting = true
	else:
		printerr("DIALOG IS MISSING FROM THIS ENTITY!")
		interacted_with = false
		_dialog_end()

func set_interaction_text(text) -> void:
	var label = Interface.hud.interaction_label
	if !text:
		label.set_text("")
		label.set_visible(false)

	else:
		var interaction_key: String = OS.get_scancode_string(InputMap.get_action_list(Device.action_main)[0].scancode).capitalize()
		var translated_prompt: String = tr("INTERFACE_INTERACTION_PROMPT")
		label.set_text(translated_prompt % [interaction_key, text])
		label.set_visible(true)

func get_interaction_text():
	return tr("INTERFACE_INTERACTION_ENTITY")

func dialog_fetcher() -> Array:
	var dialog_array: Array = []
	
	var entity_name_id: String = get_entity_identity().get_entity_name()
	entity_name_id.erase(0, 7)

	var dialog_by_id: String = "DIALOG_%s_CH%s_%s_%s_M%s_R" % [entity_name_id, EventManager.chapter, _get_time_cycle(), location.replace(" ", "").to_upper(), mood_level]

	if Utility.tr_key_exists(dialog_by_id + "0_0"):
		var result = false

		while !result:
			var key: int = randi() % 31

			var dialog_random: String = dialog_by_id + "%s" % str(key)
			if Utility.tr_key_exists(dialog_random + "_0"):
				dialog_by_id = dialog_random

				for n in 31:
					var dialog_page: String = dialog_by_id + "_%s" % str(n)
					if Utility.tr_key_exists(dialog_page):
						dialog_array.append(tr(dialog_page))
				result = true

	return dialog_array

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

## Misc ##

func _get_time_cycle() -> String:
	var t = EnvironmentMaster.time
	var t_dawn = EnvironmentMaster.time_dawn
	var t_day = EnvironmentMaster.time_day
	var t_twili = EnvironmentMaster.time_twili
	var t_night = EnvironmentMaster.time_night
	var cycle: String = ""

	if EnvironmentMaster.clear_sky:
		if t  >= 0 and t <= t_dawn:
			cycle = "CMORN"
		elif t >= t_dawn and t <= t_day:
			cycle = "CDAY"
		elif t >= t_day and t <= t_twili:
			cycle = "CTWI"
		elif t >= t_twili and t <= t_night:
			cycle = "TNIGH"

	else:
		if t  >= 0 and t <= t_dawn:
			cycle = "SMORN"
		elif t >= t_dawn and t <= t_day:
			cycle = "SDAY"
		elif t >= t_day and t <= t_twili:
			cycle = "STWI"
		elif t >= t_twili and t <= t_night:
			cycle = "SNIGH"

	return cycle

## Signals ##

func _on_Proximity_entered(body) -> void:
	if body is Interactable and body != self:
		proximity_list.append(body)

func _on_Proximity_exited(body) -> void:
	if body is Interactable and body != self:
		for t in proximity_list:
			if t == body:
				proximity_list.remove(proximity_list.find(t))

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

func set_speed(power: float) -> void:
	speed = power

func get_speed() -> float:
	return speed

func set_jump(power: int) -> void:
	jump = power

func get_jump() -> int:
	return jump

func is_submerged() -> bool:
	return submerged

class_name Entity
extends Interactable

export var identity: Resource
export var inventory: Resource

onready var states: Node = $StateController
onready var skeleton: Skeleton = $Armature/Skeleton
onready var body: MeshInstance = $"%Body"
onready var attach_point: Spatial = $"%EyePoint"
onready var proximity: Area = $Proximity

var entity_name: String
var health: int
var max_health: int
var strength: int
var speed: int
var jump: int

var direction: Vector3
var input: Vector3

var target = null

var can_interact: bool
var interacting : bool
var targeting: bool
var target_found: bool
var enemy_detected: bool
var jump_in_memory: bool
var ledge_usable: bool

var jump_memory_timer: Timer = Timer.new()
var ledge_timer: Timer = Timer.new()

func _ready() -> void:
	_set_identity()
	_set_display_health()
	_get_timers()
	ledge_usable = true
	if is_instance_valid(proximity):
		proximity.connect("area_entered", self, "_on_proximity_entered")
		proximity.connect("area_exited", self, "_on_proximity_exited")
	SB.camera.connect("target_updated", self, "_on_cam_target_updated")
	#temp until can be updated from a save file
	SB.emit_signal("health_changed", health, max_health, is_controlled())

func _input(event: InputEvent) -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if is_instance_valid(target):
		target_interact(event)
	if is_controlled():
		if event.is_action_pressed("debug_cam_fov_decrease"):
			set_entity_health(1)
		if event.is_action_pressed("debug_cam_fov_increase"):
			set_entity_health(-1)

func _physics_process(delta: float) -> void:
	if is_instance_valid(target):
		target_check()
	else:
		target = SB.utility.find_target(self, "target")
#	if is_instance_valid(identity):
#		print(identity.entity_name + " is character: " + str(is_in_group("target")))

func _integrate_forces(state: PhysicsDirectBodyState) -> void:
	pass

func _set_identity() -> void:
	if is_instance_valid(identity):
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
	health += new_amount
	if health > max_health:
		health = max_health
	elif health <= 0:
		health = 0
		kill_entity()
		print(str(self.name) +" Died")
	SB.emit_signal("health_changed", health, max_health, is_controlled())
	print(str(self.name) +" Health: " + str(health))
	_set_display_health()

func set_entity_max_health(new_amount: int) -> void:
	max_health += new_amount
	health = max_health
	SB.emit_signal("health_changed", health, max_health, is_controlled())
	print(str(self.name) +" Health: " + str(health))
	_set_display_health()

func _set_display_health() -> void:
	if is_instance_valid($DebugHealthBar):
		$DebugHealthBar.update_bar(body, health, max_health)

func _on_proximity_entered(body) -> void:
	pass

func _on_proximity_exited(body) -> void:
	pass

func kill_entity() -> void:
	SB.emit_signal("entity_killed", is_controlled())

func update_equipped() -> void:
	for child in attach_point.get_children():
		attach_point.remove_child(child)
		child.queue_free()
	if inventory.items[0] != null:
		var tool_item = inventory.items[0]
		if tool_item.item_path != "":
			var equipped_tool = load(tool_item.item_path).instance()
			equipped_tool.set_name(tool_item.item_name)
			attach_point.add_child(equipped_tool)

func target_check() -> void:
	var target_distance = target.get_global_translation().distance_to(get_global_translation())
	var max_enemy_distance = 15
	var max_interactable_distance = 2
	if Input.is_action_pressed(SB.utility.input.i_trigger_left):
		targeting = true
		if enemy_detected or !target.is_controlled() and target_distance < max_interactable_distance:
			target_found = true
		else:
			target_found = false
	else:
		target = SB.utility.find_target(self, "target")
		targeting = false

func target_interact(event: InputEvent) -> void:
	var target_distance: float  = target.get_global_translation().distance_to(get_global_translation())
	var relative_facing: float = target.get_global_transform().basis.z.dot(get_global_transform().origin - target.get_global_transform().origin)
	var max_interactable_distance: float = 2.5
#	if target.has_child("MeshInstance"):
#		target_distance = target.get_aabb().distance_to(get_global_translation())
	if is_controlled() and (!target.is_controlled() and target.character) and (target_distance < max_interactable_distance and relative_facing >= 0):
		can_interact = true
		set_interaction_text(target.get_interaction_text())
		if event.is_action_pressed(SB.utility.input.i_action_main):
			interacting = true
			target.interact()
			set_interaction_text("")
			yield(target, "interaction_ended")
			interacting = false
	else:
		can_interact = false
		set_interaction_text("")

func set_interaction_text(text) -> void:
	if !text:
		SB.game.interface.hud.interaction_label.set_text("")
		SB.game.interface.hud.interaction_label.set_visible(false)
	else:
		var interaction_key = OS.get_scancode_string(InputMap.get_action_list(SB.utility.input.i_action_main)[0].scancode)
		SB.game.interface.hud.interaction_label.set_text("Press %s to %s" % [interaction_key, text])
		SB.game.interface.hud.interaction_label.set_visible(true)

func get_interaction_text():
	return "chat"

func interact():
	trigger_dialog()

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

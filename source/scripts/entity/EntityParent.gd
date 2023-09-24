class_name EntityParent
extends RigidBody

export(Resource) var resource

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

func _ready() -> void:
	entity_name = resource.entity_name
	health = resource.health
	max_health = resource.max_health
	strength = resource.strength
	gravity = resource.gravity
	speed = resource.speed
	acceleration = resource.acceleration
	jump = resource.jump
	debug_healthbar()

func get_coords() -> Vector3:
	var x = round(global_transform.origin.x)
	var y = round(global_transform.origin.y)
	var z = round(global_transform.origin.z)
	var coords = [x, y, z]
	return coords

func set_coords(position: Vector3, angle: String) -> void:
	set_global_translation(position)
	set_global_rotation(Vector3(0, deg2rad(MathHelper.cardinal_to_degrees(angle)), 0))

func strike_flash(ar: Spatial) -> void:
	var flash = OmniLight.new()
	var tween = Tween.new()
	flash.omni_range = 10
	flash.omni_attenuation = 0
	flash.light_color = Color("00C3FF")
	flash.light_energy = 1
	flash.light_specular = 1
	flash.shadow_enabled = true
	flash.shadow_bias = 2.5
	flash.translation = ar.translation
	add_child(flash)
	add_child(tween)
	tween.interpolate_property(flash, "light_color", flash.light_color, Color("000000"), 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	yield(tween, "tween_completed")
	flash.queue_free()
	tween.queue_free()

func debug_healthbar() -> void:
	if is_instance_valid($DebugHealthBar):
		$DebugHealthBar.update_bar(health)
		if is_instance_valid($"%Body"):
			$DebugHealthBar.translation.y = $"%Body".get_aabb().size.y + 1

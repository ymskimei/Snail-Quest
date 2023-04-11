class_name EntityParent
extends KinematicBody

export(Resource) var resource

onready var entity_name : String
onready var health : int
onready var strength : int
onready var gravity : int
onready var speed : int
onready var acceleration : int
onready var jump : int

var velocity = Vector3.ZERO
var direction = Vector3.ZERO
var input = Vector3.ZERO

func _ready():
	entity_name = resource.entity_name
	health = resource.health
	strength = resource.strength
	gravity = resource.gravity
	speed = resource.speed
	acceleration = resource.acceleration
	jump = resource.jump

func get_coords():
	var x = round(global_transform.origin.x)
	var y = round(global_transform.origin.y)
	var z = round(global_transform.origin.z)
	var coords = [x, y, z]
	return coords

func set_coords(position : Vector3, angle : String):
	set_global_translation(position)
	set_global_rotation(Vector3(0, deg2rad(MathHelper.cardinal_to_degrees(angle)), 0))

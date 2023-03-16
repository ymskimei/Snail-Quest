class_name EntityParent
extends KinematicBody

export(Resource) var resource

onready var entity_name : String
onready var health : int
onready var strength : int
onready var gravity : int
onready var speed : int
onready var max_speed : int
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
	max_speed = resource.max_speed
	acceleration = resource.acceleration
	jump = resource.jump

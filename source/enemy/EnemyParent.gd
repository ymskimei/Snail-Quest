extends RigidBody

export(Resource) var resource

onready var material : Material
onready var health : int
onready var strength : int
onready var speed : int

func _ready():
	health = resource.health
	strength = resource.strength
	speed = resource.speed

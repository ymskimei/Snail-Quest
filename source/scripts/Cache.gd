extends Node

var particles: Array = [
	preload("res://assets/materials/particle/cloud.tres"),
	preload("res://assets/materials/particle/comet.tres"),
	preload("res://assets/materials/particle/constellation.tres"),
	preload("res://assets/materials/particle/rain.tres"),
	preload("res://assets/materials/particle/rain_drop.tres"),
	preload("res://assets/materials/particle/rain_ripple.tres"),
	preload("res://assets/materials/particle/star.tres"),
	preload("res://assets/materials/particle/star_color.tres")
]

func _ready():
	for particle in particles:
		var p = GPUParticles3D.new()
		p.set_process_material(particle)
		p.set_one_shot(true)
		p.set_emitting(true)
		p.hide()
		add_child(p)

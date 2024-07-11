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

func _ready() -> void:
	_cache_particles()
	add_child(SnailQuest.title.instance())

func _cache_particles() -> void:
	for particle in particles:
		var p = Particles.new()
		p.set_process_material(particle)
		p.set_one_shot(true)
		p.set_emitting(true)
		p.hide()
		add_child(p)
		p.queue_free()

func change_screen(new_scene: PackedScene):
	Device.set_block_input(true)
	Interface.transition.play("GuiTransitionFade")
	yield(Interface.transition, "animation_finished")
	get_child(0).queue_free()
	yield(get_child(0), "tree_exited")
	add_child(new_scene.instance())
	Device.set_block_input(false)
	Interface.transition.play_backwards("GuiTransitionFade")

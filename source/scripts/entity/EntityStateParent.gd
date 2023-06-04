class_name EntityStateParent
extends Node

func apply_gravity(delta):
	entity.velocity.y += -entity.gravity * delta
	entity.velocity.y = clamp(entity.velocity.y, -entity.gravity, entity.jump)

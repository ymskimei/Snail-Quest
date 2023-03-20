extends RigidBody

#var item = preload("res://assets/object/item_parent.tscn")
#var drop = preload("res://resource/item_test_1.tres")
#
#func _ready():
#	pass
#
#func _on_Area_body_entered(body):
#	drop_item(drop)
#
#func drop_item(drop):
#	item.instance().item = drop
#	get_parent().add_child(item.instance())

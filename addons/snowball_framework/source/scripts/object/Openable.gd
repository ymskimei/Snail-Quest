extends Conversable

@onready var anim: AnimationPlayer = $AnimationPlayer

var is_opened: bool

func _ready() -> void:
	character = true

func get_interaction_text() -> String:
	return "open box"

func interact() -> void: 
	if is_opened:
		anim.play("Close")
		await anim.animation_finished
		is_opened = false
		emit_signal("interaction_ended")
	else:
		anim.play("Open")
		await anim.animation_finished
		is_opened = true
		emit_signal("interaction_ended")
	#trigger_dialog()

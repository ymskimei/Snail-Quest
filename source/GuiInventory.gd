extends ColorRect

var can_pause: bool = true
onready var animator: AnimationPlayer = $AnimationPause

#func _ready():
#	set_as_toplevel(true)
#	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _gui_input(_delta):
	if can_pause and Input.is_action_just_pressed("ui_pause"):
		var tree_paused = get_tree().paused
		if !tree_paused:
			pause()
		else:
			unpause()
 
func pause():
	animator.play("Pause")
	get_tree().set_deferred("paused", true)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func unpause():
	animator.play("Unpause")
	get_tree().set_deferred("paused", false)
	set_as_toplevel(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_ReturnButton_pressed():
	unpause()

func _on_QuitButton_pressed():
	get_tree().quit()

func _on_OptionsButton_pressed():
	pass # Replace with function body.

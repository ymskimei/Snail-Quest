extends CanvasLayer

export(Resource) var model

onready var shape_slider = $"%ShapeSlider"

var is_open : bool
var shell_value: int

func _process(_delta):
	if !GuiMain.debug_open:
		if Input.is_action_just_pressed("debug_char") and !is_open and !GuiMain.game_paused:
			#GuiMain.game_paused = true
			is_open = true
			$Animation.play("Open")
		elif Input.is_action_just_pressed("debug_char") and is_open:
			#GuiMain.game_paused = false
			#get_tree().set_deferred("paused", false)
			is_open = false
			$Animation.play("Exit")
		if is_open:
			shape_slider.grab_focus()

func _physics_process(delta):
	#GlobalManager.player.update_player_appearance()
	pass

func _on_ShapeSlider_value_changed(value):
	var player = GlobalManager.player
	if shell_value != value:
		if player.is_active_player:
			player.update_shell_shape(value)
			player.update_player_appearance()
			shell_value = value

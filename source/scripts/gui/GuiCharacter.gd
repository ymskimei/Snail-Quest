extends CanvasLayer

var is_open : bool

func _process(_delta):
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
		pass

func _physics_process(delta):
	#GlobalManager.player.update_player_appearance()
	pass

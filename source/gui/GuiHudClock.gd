extends MarginContainer

func _process(_delta):
	rotate_hands()

func rotate_hands():
	if is_instance_valid(GlobalManager.game_time):
		var time = GlobalManager.game_time.get_raw_time()
		$"%HourHand".rect_rotation = time / 2
		$"%MinuteHand".rect_rotation = time * 6

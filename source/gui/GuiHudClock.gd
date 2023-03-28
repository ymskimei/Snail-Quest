extends MarginContainer


func _process(delta):
	rotate_hands()

func rotate_hands():
	var time = GameTime.get_raw_time()
	var day_percentage = GameTime.get_raw_time()
	$"%HourHand".rect_rotation = day_percentage / 2
	$"%MinuteHand".rect_rotation = day_percentage * 6

extends Label

func _process(delta):
	text = DayNightCycle.instance.get_clock_time()

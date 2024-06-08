extends Label

func _process(_delta):
	text = DayNightCycle.instance.get_clock_time()

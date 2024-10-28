extends TextureRect

@export var day_night_cycle : DayNightCycle

func _process(delta):
	var ratio = (day_night_cycle.get_daylight()-10)/20 # 0-1
	self_modulate = Color(ratio, ratio, ratio)

extends Label

var frame_times = []

func _process(delta):
	frame_times.append(delta)
	
	if frame_times.size() > 5:
		frame_times.remove_at(0)

	

func update_label():
	var sum = 0.0
	for x in frame_times:
		sum += x
	
	var avg_frame_time = sum / frame_times.size()
	
	text = str(floor(1/avg_frame_time))

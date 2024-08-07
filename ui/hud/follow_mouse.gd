extends Control

func _input(event):
	var mm_event = event as InputEventMouseMotion
	if mm_event:
		position = mm_event.position

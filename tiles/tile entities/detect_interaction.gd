extends Area2D

signal interacted

func _on_input_event(_viewport, event, _shape_idx):
	var mb_event = event as InputEventMouseButton
	if mb_event and mb_event.button_index == MOUSE_BUTTON_RIGHT and mb_event.pressed:
		interacted.emit()

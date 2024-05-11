extends Area2D

signal interacted

var hovered : bool

func _input(event):
	if !hovered:
		return
	
	var mb_event = event as InputEventMouseButton
	
	if mb_event and mb_event.button_index == 2 and mb_event.pressed:
		interacted.emit()


func _on_mouse_entered():
	hovered = true


func _on_mouse_exited():
	hovered = false

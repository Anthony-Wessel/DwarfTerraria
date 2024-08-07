class_name ItemUser
extends Node2D

static var instance : ItemUser

var instantiated_use_scene : Node
var mouse_pressed = false

func _init():
	instance = self

func _unhandled_input(event):
	var mb_event = event as InputEventMouseButton
	if mb_event:
		if mb_event.pressed and mb_event.button_index == MOUSE_BUTTON_LEFT:
			mouse_pressed = true

func _process(_delta):
	if mouse_pressed:
		if !Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			mouse_pressed = false
			return
		
		if instantiated_use_scene == null:
			var selected_item = InventoryInterface.get_selected_item()
			if selected_item == null:
				return
			if selected_item.get_use_scene() != null:
				instantiated_use_scene = selected_item.get_use_scene().instantiate()
				add_child(instantiated_use_scene)
			else:
				push_error("Trying to use item that has no use scene set: ", selected_item.name)

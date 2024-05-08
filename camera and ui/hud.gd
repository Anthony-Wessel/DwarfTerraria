class_name HUD
extends CanvasLayer

static var instance

@export var hotbar : Hotbar
@export var hand : InventoryHand
@export var storage : Control
@export var temp_inventory : Inventory

func _init():
	instance = self

func _input(event):
	var key_event = event as InputEventKey
	if key_event and key_event.pressed and key_event.keycode == KEY_ESCAPE:
		storage.open_inventory(temp_inventory)

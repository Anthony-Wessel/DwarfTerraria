class_name HUD
extends CanvasLayer

static var instance

@export var hotbar : Hotbar
@export var hand : InventoryHand
@export var storage : Control

func _init():
	instance = self

func _input(event):
	var key_event = event as InputEventKey

func open_storage(inventory : Inventory):
	storage.open_inventory(inventory)

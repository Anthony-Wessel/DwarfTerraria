class_name HUD
extends CanvasLayer

static var instance

@export var hotbar : Hotbar
@export var hand : InventoryHand

func _init():
	instance = self

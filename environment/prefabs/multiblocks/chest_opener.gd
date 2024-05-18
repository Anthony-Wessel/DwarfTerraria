extends Node

@export var inventory : Inventory

func on_interacted():
	HUD.instance.open_storage(inventory)

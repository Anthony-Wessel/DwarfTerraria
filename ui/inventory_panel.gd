extends Panel

@export var item_slot_grid : Control

func _ready():
	item_slot_grid.build(InventoryInterface.player_inventory)

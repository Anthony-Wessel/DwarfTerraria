extends Panel

@export var item_slot_grid : Control

func _ready():
	InventoryInterface.instance.storage_changed.connect(item_slot_grid.build)

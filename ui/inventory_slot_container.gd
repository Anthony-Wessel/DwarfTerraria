extends GridContainer

@export var item_slot_prefab : PackedScene

func build(inventory : Inventory):
	var inventory_size = 0
	if inventory != null:
		inventory_size = inventory.contents.size()
	
	for i in inventory_size:
		if i >= get_children().size():
			var new_slot = item_slot_prefab.instantiate()
			new_slot.slot = inventory.contents[i]
			add_child(new_slot)
		else:
			get_child(i).slot = inventory.contents[i]
			get_child(i).visible = true

	if inventory_size < get_children().size():
		for i in range(inventory_size, get_children().size()):
			get_child(i).slot = null
			get_child(i).visible = false

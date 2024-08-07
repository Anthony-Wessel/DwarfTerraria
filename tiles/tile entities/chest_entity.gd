extends Entity

@export var inventory_size := 30

var inventory : Inventory

func _init():
	inventory = Inventory.new(inventory_size)

func on_interacted():
	InventoryInterface.open_storage(inventory)

func save_data() -> Dictionary:
	var result := {}
	
	for i in inventory.contents.size():
		var stack = inventory.contents[i].contents
		if stack.item != null:
			result[i] = stack
	
	return result

func load_data(data : Dictionary):
	print("load data")
	for index in data.keys():
		inventory.contents[index].add(data[index])

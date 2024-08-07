class_name Inventory
extends Resource

signal inventory_updated
@export var contents : Array[InventorySlot]

func _init(size : int):
	for i in size:
		contents.append(InventorySlot.new())

# returns remainder that couldn't be added
func add_stack(stack : ItemStack) -> ItemStack:
	for slot in contents:
		stack = slot.add(stack)
		if stack.count == 0:
			break
	
	return stack

func remove_stack(stack : ItemStack):
	for slot in contents:
		if slot.item == stack.item:
			if stack.count >= slot.count:
				stack.count -= slot.count
				slot.remove(slot.count)
			else:
				slot.remove(stack.count)
				stack.count = 0
			
			if stack.count == 0:
				return
	
	push_error("tried to remove too much from inventory")

func has_stack(stack : ItemStack) -> bool:
	var found_count = 0
	for slot in contents:
		if slot.item == stack.item:
			found_count += slot.count
			if found_count >= stack.count:
				return true
	
	return false

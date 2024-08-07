class_name InventorySlot
extends Resource

signal contents_updated
@export var contents : ItemStack

var item : get = get_item, set = set_item
func get_item() -> Item:
	return contents.item
func set_item(value):
	contents.item = value

var count : get = get_count, set = set_count
func get_count() -> int:
	return contents.count
func set_count(value):
	contents.count = value

func _init():
	contents = ItemStack.new()

# returns previous contents
func replace(stack : ItemStack) -> ItemStack:
	var old_contents = ItemStack.new(item, count)
	item = stack.item
	count = stack.count
	
	contents_updated.emit()
	return old_contents

# returns remainder that couldn't be added
func add(stack : ItemStack) -> ItemStack:
	if item == null:
		item = stack.item
		count = stack.count
		
		contents_updated.emit()
		return ItemStack.new(null,0)
	
	if stack.item == item:
		count += stack.count
		if count > item.stack_size:
			stack.count = count - item.stack_size
			count = item.stack_size
		else:
			stack.count = 0
		contents_updated.emit()
		return stack
	
	return stack

func remove(amount : int):
	count -= amount
	if count < 0:
		push_error("Tried to remove too much from slot")
		count = 0
	contents_updated.emit()

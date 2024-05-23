class_name Inventory
extends Node


@export var size := 60
@export var default_items : Array[Item]
@export var default_items_count : Array[int]

var contents : Array[ItemStack]
signal inventory_updated(updated_contents : Array[ItemStack])

func _ready():
	for i in range(size):
		contents.append(ItemStack.new())
	
	# Add the default items
	for i in range(default_items.size()):
		add_items(default_items[i], default_items_count[i])

func add_item(item : Item):
	add_items(item, 1)

func remove_item(item : Item):
	remove_items(item, 1)

func remove_items(item : Item, count : int):
	for stack in contents:
		if stack.item == item:
			if stack.count >= count:
				stack.count -= count
				if stack.count == 0:
					stack.item = null
				inventory_updated.emit(contents)
				return
			else:
				count = count - stack.count
				stack.count = 0
				stack.item = null

func remove_from_slot(slot : int, count : int):
	if contents[slot].count < count:
		return false
	
	contents[slot].count -= count
	if contents[slot].count == 0:
		contents[slot].item = null
	
	inventory_updated.emit(contents)
	return true

func add_items(item : Item, count : int) -> bool :
	if item == null:
		print("Can't add null item")
		return false
	var first_null = null
	for stack in contents:
		if stack.item == null and first_null == null:
			first_null = stack
		elif stack.item == item:
			stack.count += count
			inventory_updated.emit(contents)
			return true
	
	if first_null == null:
		return false
	else:
		first_null.item = item
		first_null.count = count
		inventory_updated.emit(contents)
		return true

func swap_stack(new_stack : ItemStack, slot_index : int) -> ItemStack :
	var removed_stack = contents[slot_index]
	contents[slot_index] = new_stack
	
	inventory_updated.emit(contents)
	
	return removed_stack

func has_items(item : Item, minimum_count : int) -> bool :
	var total = 0
	for stack in contents:
		if stack.item == item:
			total += stack.count
			if total >= minimum_count:
				return true
	
	return false

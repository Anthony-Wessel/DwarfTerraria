class_name Inventory
extends Node

@export var size := 16
var contents : Array[ItemStack]
signal inventory_updated(updated_contents : Array[ItemStack])

func _init():
	for i in range(size):
		contents.append(ItemStack.new())

func add_item(item : Item):
	var first_null = null
	for stack in contents:
		if stack.item == null and first_null == null:
			first_null = stack
		elif stack.item == item:
			stack.count += 1
			inventory_updated.emit(contents)
			return
	
	if first_null == null:
		return null
	else:
		first_null.item = item
		first_null.count = 1
		inventory_updated.emit(contents)

func remove_item(item : Item):
	for stack in contents:
		if stack.item == item:
			stack.count -= 0
			if stack.count == 0:
				stack.item = null
			inventory_updated.emit(contents)



class ItemStack:
	var item : Item
	var count : int
	
	func _init():
		item = null
		count = 0

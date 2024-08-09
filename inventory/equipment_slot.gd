class_name EquipmentSlot
extends InventorySlot

@export var type : EquipmentItem.Type

func set_item(value):
	if value is EquipmentItem and value.type == type:
		contents.item = value

func _init(equipment_type : EquipmentItem.Type):
	type = equipment_type
	super()

# returns previous contents
func replace(stack : ItemStack) -> ItemStack:
	if not stack.item is EquipmentItem or stack.item.type != type:
		if stack.item != null:
			return stack
	
	return super(stack)

# returns remainder that couldn't be added
func add(stack : ItemStack) -> ItemStack:
	if not stack.item is EquipmentItem or stack.item.type != type:
		return stack
	
	return super(stack)

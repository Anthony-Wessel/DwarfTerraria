extends Panel

# add 1 element for each child slot
@export var equipment_types : Array[EquipmentItem.Type]

func _ready():
	var slots = get_children()
	if slots.size() != equipment_types.size():
		push_error("Size of equipment_types array does not match number of slot nodes")
	
	for i in slots.size():
		var slot = EquipmentSlot.new(equipment_types[i])
		slots[i].slot = slot
		InventoryInterface.add_equipment_slot(slot)

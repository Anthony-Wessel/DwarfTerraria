extends Control

@export var display_slots : Array[TextureRect]
@export var test_item : Item

func _ready():
	GlobalReferences.player.inventory.inventory_updated.connect(update_display)

func update_display(new_contents : Array[Inventory.ItemStack]):
	for i in range(min(display_slots.size(), new_contents.size())):
		if new_contents[i].item == null:
			display_slots[i].texture = null
		else:
			display_slots[i].texture = new_contents[i].item.image

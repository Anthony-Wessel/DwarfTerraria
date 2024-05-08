extends Control

var current_inventory : Inventory
@export var slot_container : Control
var display_slots : Array[InventoryTile]

func _ready():
	for child in slot_container.get_children():
		display_slots.append(child)
	
	for i in display_slots.size():
		var lambda = func():
			if current_inventory != null:
				HUD.instance.hand.hover_updated(current_inventory, i)
		display_slots[i].mouse_entered.connect(lambda)
	
	HUD.instance.hotbar.inventory_panel_closed.connect(close)
	

func open_inventory(inventory : Inventory):
	current_inventory = inventory
	$TextureRect.visible = true
	
	HUD.instance.hotbar.inventory_root.visible = true
	HUD.instance.hand.other_inventory = inventory
	inventory.inventory_updated.connect(update_display)

func close():
	current_inventory.inventory_updated.disconnect(update_display)
	current_inventory = null
	$TextureRect.visible = false

func update_display(new_contents : Array[Inventory.ItemStack]):
	for i in range(min(display_slots.size(), new_contents.size())):
		display_slots[i].update(new_contents[i])

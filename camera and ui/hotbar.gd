class_name Hotbar
extends Control

@export var inventory_root : Control
@export var hotbar_container : Control
@export var inventory_container : Control
var display_slots : Array[InventoryTile]

signal inventory_panel_closed

@export var highlight : Control
signal on_selected_item_changed(new_item : Item)

var selected_slot := 0
var inventory : Inventory
var hand : InventoryHand

var hotbar_keycodes = [49,50,51,52,53,54,55,56,57,48,45,61]

func _ready():
	hand = HUD.instance.hand
	
	# Connect to player's inventory
	inventory = Player.instance.inventory
	inventory.inventory_updated.connect(update_display)
	
	# Grab a reference for each item slot
	for slot in hotbar_container.get_children():
		display_slots.append(slot)
	for slot in inventory_container.get_children():
		display_slots.append(slot)
	
	for i in display_slots.size():
		var lambda = func():
			if inventory_root.visible:
				hand.hover_updated(inventory, i)
		display_slots[i].mouse_entered.connect(lambda)


func update_display(new_contents : Array[Inventory.ItemStack]):
	selected_item_changed()
	for i in range(min(display_slots.size(), new_contents.size())):
		display_slots[i].update(new_contents[i])

func selected_item_changed():
	on_selected_item_changed.emit(inventory.contents[selected_slot].item)

func _input(event):
	var slot_changed = false
	
	if event is InputEventKey:
		var key_event = event as InputEventKey
		if !key_event.is_pressed():
			return
		
		if key_event.keycode == KEY_TAB:
			inventory_root.visible = !inventory_root.visible
			if !inventory_root.visible:
				inventory_panel_closed.emit()
		
		var index = hotbar_keycodes.find(key_event.keycode)
		if index != -1:
			if selected_slot != index:
				selected_slot = index
				slot_changed = true
			
	elif event is InputEventMouseButton:
		var mb_event = event as InputEventMouseButton
		if !mb_event.is_pressed():
			return
		
		# Scroll wheel to select slot
		if mb_event.button_index == 5:
			selected_slot += 1
			if selected_slot >= 12:
				selected_slot = 0
			slot_changed = true
		elif mb_event.button_index == 4:
			selected_slot -= 1
			if selected_slot < 0:
				selected_slot = 11
			slot_changed = true
	
	highlight.reparent(display_slots[selected_slot], false)
	if slot_changed:
		on_selected_item_changed.emit(inventory.contents[selected_slot].item)
	

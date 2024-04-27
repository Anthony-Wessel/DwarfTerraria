class_name Hotbar
extends Control

@export var display_slots : Array[TextureRect]
@export var default_items : Array[Item]

@export var highlight : Node
signal on_selected_item_changed(new_item : Item)

var selected_slot := 0
var inventory : Inventory
var tileGrid : GameWorld

var hotbar_keycodes = [49,50,51,52,53,54,55,56,57,48,45,61, 4194438, 4194439, 4194440, 4194441]

func _ready():
	tileGrid = GameWorld.instance
	inventory = Player.instance.inventory
	inventory.inventory_updated.connect(update_display)
	for i in range(default_items.size()):
		inventory.add_item(default_items[i])
	selected_item_changed()


func update_display(new_contents : Array[Inventory.ItemStack]):
	selected_item_changed()
	for i in range(min(display_slots.size(), new_contents.size())):
		if new_contents[i].item == null:
			display_slots[i].texture = null
		else:
			display_slots[i].texture = new_contents[i].item.texture

func selected_item_changed():
	on_selected_item_changed.emit(inventory.contents[selected_slot].item)

func _input(event):
	var slot_changed = false
	
	if event is InputEventKey:
		var key_event = event as InputEventKey
		if !key_event.is_pressed():
			return
		
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
		if mb_event.button_index == 4:
			selected_slot += 1
			if selected_slot >= display_slots.size():
				selected_slot = 0
			slot_changed = true
		elif mb_event.button_index == 5:
			selected_slot -= 1
			if selected_slot < 0:
				selected_slot = display_slots.size()-1
			slot_changed = true
	
	highlight.reparent(display_slots[selected_slot], false)
	if slot_changed:
		on_selected_item_changed.emit(inventory.contents[selected_slot].item)
	

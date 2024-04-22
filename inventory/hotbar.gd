extends Control

@export var display_slots : Array[TextureRect]
@export var default_items : Array[Item]

@export var highlight : Node

var selected_slot := 0
var inventory : Inventory
var tileGrid : GameWorld

func _ready():
	tileGrid = GlobalReferences.gameWorld
	inventory = GlobalReferences.player.inventory
	inventory.inventory_updated.connect(update_display)
	for i in range(default_items.size()):
		inventory.add_item(default_items[i])

func update_display(new_contents : Array[Inventory.ItemStack]):
	for i in range(min(display_slots.size(), new_contents.size())):
		if new_contents[i].item == null:
			display_slots[i].texture = null
		else:
			display_slots[i].texture = new_contents[i].item.texture

func _input(event):
	var mb_event = event as InputEventMouseButton
	if !mb_event:
		return
	if !mb_event.is_pressed():
		return
	
	# Scroll wheel to select slot
	if mb_event.button_index == 4:
		selected_slot += 1
		if selected_slot >= display_slots.size():
			selected_slot = 0
	elif mb_event.button_index == 5:
		selected_slot -= 1
		if selected_slot < 0:
			selected_slot = display_slots.size()-1
	
	highlight.reparent(display_slots[selected_slot], false)
	
	var tile_pos = Vector2i(tileGrid.get_local_mouse_position()/8)
	var item = inventory.contents[selected_slot].item
	
	if mb_event.button_index == 1:
		if item is TileItem:
			tileGrid.set_tile(tile_pos.x ,tile_pos.y, inventory.contents[selected_slot].item)
		elif item is ToolItem:
			tileGrid.set_tile(tile_pos.x ,tile_pos.y, null)
		elif item is WeaponItem:
			GlobalReferences.player.attack()

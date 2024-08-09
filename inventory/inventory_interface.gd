class_name InventoryInterface
extends Node

const hotbar_size = 12
const player_inventory_size = 60

@export var default_items : Array[ItemStack]

signal selected_item_changed(Item)
signal held_stack_changed(ItemStack)
signal storage_changed(inventory)

static var instance : InventoryInterface

static var player_equipment : Inventory
static var player_inventory : Inventory
static var storage_inventory : Inventory : set = set_storage
static func set_storage(value):
	if storage_inventory == value:
		storage_inventory = null
	else:
		storage_inventory = value
	instance.storage_changed.emit(storage_inventory)

static var held_stack : ItemStack : set = set_held_stack
static func set_held_stack(value):
	held_stack = value
	instance.held_stack_changed.emit(held_stack)
	instance.emit_selected_item()

static var selected_hotbar_slot = 0 

static func get_selected_item():
	if held_stack != null and held_stack.item != null:
		return held_stack.item
	else:
		return player_inventory.contents[selected_hotbar_slot].item

func _init():
	instance = self
	player_inventory = Inventory.new(player_inventory_size)
	held_stack = ItemStack.new()

func _ready():
	for item in default_items:
		if !player_inventory.has_stack(item):
			player_inventory.add_stack(item)

static func add_equipment_slot(new_slot : InventorySlot):
	if instance.player_equipment == null:
		instance.player_equipment = Inventory.new(0)
	
	instance.player_equipment.contents.append(new_slot)

static func load_player_inventory(player_save : PlayerSave):
	for index in player_save.inventory_contents.keys():
		player_inventory.contents[index].add(player_save.inventory_contents[index])

static func open_storage(storage : Inventory):
	storage_inventory = storage

static func used_selected_item():
	if held_stack.item != null:
		held_stack.count -= 1
		instance.held_stack_changed.emit(held_stack)
	else:
		player_inventory.contents[selected_hotbar_slot].remove(1)
	
	instance.emit_selected_item()

# Inventory functionality
static func on_slot_interaction(slot : InventorySlot, lmb : bool):
	match lmb:
		true:
			if Input.is_key_pressed(KEY_SHIFT):
				pass
			else:
				if held_stack.item == slot.item:
					held_stack = slot.add(held_stack)
				else:
					held_stack = slot.replace(held_stack)
		false:
			if held_stack.item == null:
				var half = ceil(slot.count/2.0)
				held_stack = ItemStack.new(slot.item, half)
				slot.remove(half)
			else:
				if slot.add(ItemStack.new(held_stack.item, 1)).count == 0:
					held_stack.count -= 1
					instance.held_stack_changed.emit(held_stack)

func emit_selected_item():
	selected_item_changed.emit(get_selected_item())

static func set_selected_hotbar_slot(slot_index : int):
	selected_hotbar_slot = slot_index
	instance.emit_selected_item()

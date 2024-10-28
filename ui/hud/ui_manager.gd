class_name GUI
extends CanvasLayer

static var instance

@export var inventory_root : Control
@export var hotbar_root : Control
@export var storage_root : Control
@export var crafting_panel : Control

func _init():
	instance = self

func _ready():
	InventoryInterface.instance.storage_changed.connect(update_storage_gui)

func update_storage_gui(inventory):
	if inventory == null:
		storage_root.visible = false
	else:
		storage_root.visible = true
		if !inventory_root.visible:
			toggle_inventory()

func _input(event):
	var key_event = event as InputEventKey
	if key_event and key_event.pressed:
		if key_event.keycode == KEY_TAB:
			toggle_inventory()

static func toggle_inventory():
	instance.crafting_panel.open()
	
	instance.inventory_root.visible = !instance.inventory_root.visible
	instance.hotbar_root.visible = !instance.inventory_root.visible
	
	if !instance.inventory_root.visible:
		instance.storage_root.visible = false
		InventoryInterface.storage_inventory = null

static func open_inventory():
	if !instance.inventory_root.visible:
		toggle_inventory()

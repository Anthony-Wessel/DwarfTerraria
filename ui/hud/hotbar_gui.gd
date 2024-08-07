extends Control

@export var slot_prefab : PackedScene
@export var slot_container : Control
@export var highlight : Control

var hotbar_size : int
var selected_slot : int : set=set_selected_slot
func set_selected_slot(value):
	if value < 0 or value >= hotbar_size:
		push_error("Trying to select slot outside hotbar bounds: ", value)
		return
	
	selected_slot = value
	update_highlight()
	InventoryInterface.set_selected_hotbar_slot(selected_slot)

func _ready():
	hotbar_size = InventoryInterface.hotbar_size
	var player_inventory = InventoryInterface.player_inventory
	for i in hotbar_size:
		var new_slot = slot_prefab.instantiate()
		new_slot.slot = player_inventory.contents[i]
		slot_container.add_child(new_slot)
	
	selected_slot = 0

func _unhandled_input(event):
	if event is InputEventMouseButton:
		handle_mouse_input(event)
	elif event is InputEventKey:
		handle_key_input(event)


# Input #
func handle_mouse_input(mouse_event : InputEventMouseButton):
	if mouse_event.pressed:
		match mouse_event.button_index:
			MOUSE_BUTTON_WHEEL_DOWN:
				selected_slot = (selected_slot+1) % hotbar_size
			MOUSE_BUTTON_WHEEL_UP:
				var next_slot = selected_slot - 1
				if next_slot < 0:
					next_slot = hotbar_size-1
					
				selected_slot = next_slot

var hotbar_keycodes = [49,50,51,52,53,54,55,56,57,48,45,61]
func handle_key_input(key_event : InputEventKey):
	if key_event.pressed:
		var slot_number = hotbar_keycodes.find(key_event.keycode)
		if slot_number != -1 and slot_number != selected_slot:
			selected_slot = slot_number


# Highlight #
func update_highlight():
	highlight.reparent(slot_container.get_child(selected_slot), false)

class_name InventoryHand
extends Control

var hovered_inventory : Inventory
var hovered_index : int

var held_stack : Inventory.ItemStack

func _init():
	held_stack = Inventory.ItemStack.new()

func hover_updated(inventory : Inventory, index : int):
	hovered_inventory = inventory
	hovered_index = index
	#print(index)

func _input(event):
	var mb_event = event as InputEventMouseButton
	if mb_event:
		if mb_event.pressed and mb_event.button_index == 1:
			if hovered_inventory == null:
				return
			
			# swap held_stack with hovered inventory slot
			held_stack = hovered_inventory.swap_stack(held_stack, hovered_index)
			
			if held_stack.item == null:
				$TextureRect.texture = null
			else:
				$TextureRect.texture = held_stack.item.texture

func _process(delta):
	$TextureRect.position = get_local_mouse_position() - Vector2(32,32)

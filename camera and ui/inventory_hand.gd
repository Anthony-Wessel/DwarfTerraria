class_name InventoryHand
extends Control

var hovered_inventory : Inventory
var hovered_index : int

var held_stack : ItemStack

var player_inventory : Inventory
var other_inventory : Inventory

func _init():
	held_stack = ItemStack.new()

func _ready():
	player_inventory = Player.instance.inventory
	HUD.instance.hotbar.inventory_panel_closed.connect(on_inventory_panel_closed)

func hover_updated(inventory : Inventory, index : int):
	hovered_inventory = inventory
	hovered_index = index

func _input(event):
	if hovered_inventory == null:
		return
	
	var mb_event = event as InputEventMouseButton
	if mb_event:
		# Left CLick
		if mb_event.pressed and mb_event.button_index == 1:
			if hovered_inventory == null:
				return
			# Shift click
			if Input.is_key_pressed(KEY_SHIFT):
				if other_inventory == null:
					return
				# Get the clicked stack
				var stack = hovered_inventory.contents[hovered_index]
				
				# Get the inventory that the stack is being transferred TO
				var temp = other_inventory
				if hovered_inventory == other_inventory:
					temp = player_inventory
				
				# Transfer the stack
				var successfully_added = temp.add_items(stack.item, stack.count)
				if successfully_added:
					hovered_inventory.remove_from_slot(hovered_index, stack.count)
			
			# Regular click
			else:
				# swap held_stack with hovered inventory slot
				held_stack = hovered_inventory.swap_stack(held_stack, hovered_index)
			

		# Right Click
		elif mb_event.pressed and mb_event.button_index == 2:
			if held_stack.item == null:
				var clicked_stack = hovered_inventory.contents[hovered_index]
				if clicked_stack.item == null:
					return
				
				held_stack.count = ceil(clicked_stack.count/2.0)
				if held_stack.count > 0:
					held_stack.item = clicked_stack.item
				
					clicked_stack.count -= held_stack.count
					if clicked_stack.count == 0:
						clicked_stack.item = null
					
					hovered_inventory.inventory_updated.emit(hovered_inventory.contents)
	
	if held_stack.item == null:
		$TextureRect.texture = null
	else:
		$TextureRect.texture = held_stack.item.texture

func _process(_delta):
	$TextureRect.position = get_local_mouse_position() - Vector2(32,32)

func on_inventory_panel_closed():
	if held_stack.item != null:
		var successfully_added = player_inventory.add_items(held_stack.item, held_stack.count)
		if !successfully_added:
			PickupFactory.spawn_pickup(held_stack.item, Player.instance.position)
			pass
	
		held_stack.item = null
		held_stack.count = 0
	
	other_inventory = null
	$TextureRect.texture = null

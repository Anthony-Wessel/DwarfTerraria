extends Control

@export var display_slots : Array[TextureRect]
@export var default_items : Array[Item]

@export var highlight : Node

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

func update_display(new_contents : Array[Inventory.ItemStack]):
	for i in range(min(display_slots.size(), new_contents.size())):
		if new_contents[i].item == null:
			display_slots[i].texture = null
		else:
			display_slots[i].texture = new_contents[i].item.texture

func _input(event):
	if event is InputEventKey:
		var key_event = event as InputEventKey
		if !key_event.is_pressed():
			return
		
		var index = hotbar_keycodes.find(key_event.keycode)
		if index != -1:
			selected_slot = index
			
	elif event is InputEventMouseButton:
		var mb_event = event as InputEventMouseButton
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

func _process(delta):
	_handle_mouse_input(delta)
	
func _handle_mouse_input(delta):
	var selected_item = inventory.contents[selected_slot].item
	
	if selected_item is ToolItem:
		_handle_tool_usage(selected_item, delta)
	elif selected_item is WeaponItem:
		_handle_weapon_usage(selected_item, delta)
	elif selected_item is TileItem:
		_handle_tile_usage(selected_item, delta)


func _handle_tool_usage(tool: ToolItem, delta):
	if Input.is_action_pressed("mb_left"):
		var tile_pos = Vector2i(tileGrid.get_local_mouse_position()/8)
		var distance_to_player = Player.instance.global_position - (tileGrid.global_position+Vector2(tile_pos)*8)
		if distance_to_player.length() <= 5*8:
			tileGrid.mine_tile(tile_pos.x ,tile_pos.y, tool.mining_tier, tool.mining_speed*delta)


func _handle_weapon_usage(weapon: WeaponItem, delta):
	if Input.is_action_just_pressed("mb_left"):
		Player.instance.attack()


func _handle_tile_usage(tile: TileItem, delta):
	if Input.is_action_pressed("mb_left"):
		# Determine what tile the mouse is hovering over
		var tile_pos = Vector2i(tileGrid.get_local_mouse_position()/8)
		
		# Don't place a tile if it is out of reach
		var distance_to_player = Player.instance.global_position - (tileGrid.global_position+Vector2(tile_pos)*8)
		if distance_to_player.length() > 5*8:
			return
			
		# If the hovered tile is already the selected item, don't do anything
		if tileGrid.get_tile(tile_pos.x ,tile_pos.y).item == tile:
			return
		
		# Place the selected tile item
		tileGrid.set_tile(tile_pos.x, tile_pos.y, tile)
		inventory.remove_item(tile)


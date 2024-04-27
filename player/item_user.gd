extends Node

var held_item : Item
var tile_grid : GameWorld
var inventory : Inventory

func _init():
	HUD.instance.hotbar.on_selected_item_changed.connect(swap_item)

func _ready():
	tile_grid = GameWorld.instance
	inventory = get_node("../Inventory")

func swap_item(new_item : Item):
	held_item = new_item

func _process(delta):
	if held_item is TileItem:
		handle_tile_usage(held_item, delta)
	elif held_item is ToolItem:
		handle_tool_usage(held_item, delta)
	elif held_item is WeaponItem:
		handle_weapon_usage(held_item, delta)

func handle_tile_usage(tile : TileItem, delta):
	if Input.is_action_pressed("mb_left"):
		# Determine what tile the mouse is hovering over
		var tile_pos = Vector2i(tile_grid.get_local_mouse_position()/8)
		
		# Don't place a tile if it is out of reach
		var distance_to_player = get_parent().global_position - (tile_grid.global_position+Vector2(tile_pos)*8)
		if distance_to_player.length() > 5*8:
			return
			
		# If the hovered tile is already the selected item, don't do anything
		if tile_grid.get_tile(tile_pos.x ,tile_pos.y).item == tile:
			return
		
		# Place the selected tile item
		tile_grid.set_tile(tile_pos.x, tile_pos.y, tile)
		inventory.remove_item(tile)

func handle_tool_usage(tool : ToolItem, delta):
	if Input.is_action_pressed("mb_left"):
		var tile_pos = Vector2i(tile_grid.get_local_mouse_position()/8)
		var distance_to_player = Player.instance.global_position - (tile_grid.global_position+Vector2(tile_pos)*8)
		if distance_to_player.length() <= 5*8:
			tile_grid.mine_tile(tile_pos.x ,tile_pos.y, tool.mining_tier, tool.mining_speed*delta)

func handle_weapon_usage(weapon : WeaponItem, delta):
	if Input.is_action_just_pressed("mb_left"):
		Player.instance.attack()

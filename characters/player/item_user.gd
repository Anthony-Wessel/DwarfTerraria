extends Node2D

var held_item : Item
var tile_grid : GameWorld
@export var inventory : Inventory

@export var held_prefab : HeldItem

@export var preview_sprite : Node2D
var preview_intersections : Array[bool]
var prev_pos : Vector2i

func _init():
	HUD.instance.hotbar.on_selected_item_changed.connect(swap_item)

func _ready():
	tile_grid = GameWorld.instance
	for i in 9:
		preview_intersections.append(false)

func swap_item(new_item : Item):
	preview_sprite.clear()
	held_item = new_item
	
	if new_item == null:
		return
	
	if new_item is TileItem or new_item is MultiblockItem:
		var tile_pos = Vector2i(tile_grid.get_local_mouse_position()/8)
		update_preview_sprite(tile_pos)
	
	held_prefab.set_sprite(new_item.held_texture)
	var weapon = new_item as WeaponItem
	if weapon:
		held_prefab.set_collision(weapon.collision_shape)

func _process(delta):
	if held_item is TileItem:
		handle_tile_usage(held_item, delta)
	if held_item is MultiblockItem:
		handle_multiblock_usage(held_item, delta)
	elif held_item is ToolItem:
		handle_tool_usage(held_item, delta)
	elif held_item is WeaponItem:
		handle_weapon_usage(held_item, delta)

func handle_tile_usage(tile : TileItem, delta):
	# Determine what tile the mouse is hovering over
	var tile_pos = Vector2i(tile_grid.get_local_mouse_position()/8)
	if tile_pos != prev_pos:
		update_preview_sprite(tile_pos)
		
	if Input.is_action_pressed("mb_left"):
		if preview_intersections[0]:
			return
		
		held_prefab.use("use_tile", 5.0)
		
		# Place the selected tile item
		tile_grid.set_tile(tile_pos.x, tile_pos.y, tile)
		inventory.remove_item(tile)
		
		update_preview_sprite(tile_pos)

func handle_multiblock_usage(multiblock : MultiblockItem, delta):
	# Determine what tile the mouse is hovering over
	var tile_pos = Vector2i(tile_grid.get_local_mouse_position()/8)
	if tile_pos != prev_pos:
		update_preview_sprite(tile_pos)
	
	if Input.is_action_pressed("mb_left"):
		for intersection in preview_intersections:
			if intersection:
				return
		held_prefab.use("use_tile", 5.0)
		
		# Place the selected multiblock item
		tile_grid.set_multiblock(tile_pos.x, tile_pos.y, multiblock)
		inventory.remove_item(multiblock)
		
		update_preview_sprite(tile_pos)

func handle_tool_usage(tool : ToolItem, delta):
	if Input.is_action_pressed("mb_left"):
		held_prefab.use("use_tool", tool.mining_speed)
		var tile_pos = Vector2i(tile_grid.get_local_mouse_position()/8)
		var distance_to_player = global_position - (tile_grid.global_position+Vector2(tile_pos)*8)
		if distance_to_player.length() <= 5*8:
			tile_grid.mine_tile(tile_pos.x ,tile_pos.y, tool.mining_tier, tool.mining_speed*delta)

func handle_weapon_usage(weapon : WeaponItem, delta):
	if Input.is_action_just_pressed("mb_left"):
		held_prefab.use("use_weapon", weapon.speed)

func handle_hit(body):
	var diff = body.global_position - global_position
	(body as CharacterMovement).force_velocity(Vector2(sign(diff.x)*70,-50))
	

func update_preview_sprite(new_pos : Vector2i):
	if held_item == null:
		return
	preview_sprite.update_texture(held_item.texture)
	preview_sprite.global_position = tile_grid.global_position+Vector2(new_pos)*8
	
	# Don't place a tile if it is out of reach
	var distance_to_player = global_position - (tile_grid.global_position+Vector2(new_pos)*8)
	if distance_to_player.length() > 5*8:
		for i in preview_intersections.size():
			preview_intersections[i] = true
	else:
		for i in preview_intersections.size():
			preview_intersections[i] = false
		var multiblock = held_item as MultiblockItem
		if multiblock:
			for a in multiblock.size.x:
				for b in multiblock.size.y:
					var t = tile_grid.get_tile(new_pos.x+a ,new_pos.y+b)
					if t != null and !t.empty:
						preview_intersections[a+b*3] = true
					else:
						preview_intersections[a+b*3] = false
		else: # If the hovered tile is not empty, don't allow placement
			var t = tile_grid.get_tile(new_pos.x ,new_pos.y)
			if t != null and !t.empty:
				preview_intersections[0] = true
			else:
				preview_intersections[0] = false
	
	preview_sprite.update_intersections(preview_intersections)

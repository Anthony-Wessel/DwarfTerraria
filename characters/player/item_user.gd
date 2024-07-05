extends Node2D

var held_item : Item
var tile_grid : GameWorld
var miner : Miner
@export var inventory : Inventory

@export var held_prefab : HeldItem

@export var preview_sprite : Node2D
var preview_intersections : Array[bool]
var prev_pos : Vector2i

func _init():
	HUD.instance.hotbar.on_selected_item_changed.connect(swap_item)

func _ready():
	tile_grid = GameWorld.instance
	miner = Miner.instance
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

func handle_tile_usage(tile : TileItem, _delta):
	# Determine what tile the mouse is hovering over
	var tile_pos = Vector2i(tile_grid.get_local_mouse_position()/GlobalReferences.TILE_SIZE)
	if tile_pos != prev_pos:
		update_preview_sprite(tile_pos)
		
	if Input.is_action_pressed("mb_left"):
		if preview_intersections[0]:
			return
		
		held_prefab.use("use_tile", 5.0)
		
		# Place the selected tile item
		tile_grid.place_tile(tile_pos, tile)
		inventory.remove_item(tile)
		
		update_preview_sprite(tile_pos)

func handle_multiblock_usage(multiblock : MultiblockItem, _delta):
	# Determine what tile the mouse is hovering over
	var tile_pos = Vector2i(tile_grid.get_local_mouse_position()/GlobalReferences.TILE_SIZE)
	if tile_pos != prev_pos:
		update_preview_sprite(tile_pos)
	
	if Input.is_action_pressed("mb_left"):
		for intersection in preview_intersections:
			if intersection:
				return
		held_prefab.use("use_tile", 5.0)
		
		# Place the selected multiblock item
		tile_grid.place_multiblock(tile_pos, multiblock, true)
		inventory.remove_item(multiblock)
		
		update_preview_sprite(tile_pos)

var corner_offsets = [Vector2(-3,-3), Vector2(3,-3), Vector2(3,3), Vector2(-3,3)]
func handle_tool_usage(tool : ToolItem, delta):
	if Input.is_action_pressed("mb_left"):
		held_prefab.use("use_tool", tool.mining_speed)
		var targeted_tiles : Array[Vector2i]
		
		if Input.is_key_pressed(KEY_SHIFT):
			for offset in corner_offsets:
				var corner = Vector2i((tile_grid.get_local_mouse_position() + offset)/GlobalReferences.TILE_SIZE)
				if !targeted_tiles.has(corner):
					targeted_tiles.append(corner)
		else:
			targeted_tiles = [Vector2i(tile_grid.get_local_mouse_position()/GlobalReferences.TILE_SIZE)]
		
		for tile_pos in targeted_tiles:
			var distance_to_player = global_position - (Vector2(tile_pos)*GlobalReferences.TILE_SIZE)
			if distance_to_player.length() > 5*GlobalReferences.TILE_SIZE:
				targeted_tiles.erase(tile_pos)
		
		miner.instance.mine_tile(targeted_tiles, tool.mining_tier, tool.mining_speed*delta, tool.mines_walls)
				

func handle_weapon_usage(weapon : WeaponItem, _delta):
	if Input.is_action_just_pressed("mb_left"):
		held_prefab.use("use_weapon", weapon.speed)

func handle_hit(body):
	var diff = body.global_position - global_position
	(body as CharacterMovement).force_velocity(Vector2(sign(diff.x)*70,-50))
	

func update_preview_sprite(new_pos : Vector2i):
	if held_item == null:
		return
	preview_sprite.update_texture(held_item.texture)
	preview_sprite.global_position = tile_grid.global_position+Vector2(new_pos)*GlobalReferences.TILE_SIZE
	
	if preview_sprite.is_overlapping_player():
		for i in preview_intersections.size():
			preview_intersections[i] = true
			
		preview_sprite.update_intersections(preview_intersections)
		return
	
	# Don't place a tile if it is out of reach
	var distance_to_player = global_position - (Vector2(new_pos)*GlobalReferences.TILE_SIZE)
	if distance_to_player.length() > 5*GlobalReferences.TILE_SIZE:
		for i in preview_intersections.size():
			preview_intersections[i] = true
	else:
		for i in preview_intersections.size():
			preview_intersections[i] = false
		var multiblock = held_item as MultiblockItem
		# placing multiblock
		if multiblock:
			for a in multiblock.size.x:
				for b in multiblock.size.y:
					if !tile_grid.is_tile_empty(new_pos + Vector2i(a,b)):
						preview_intersections[a+b*3] = true
					else:
						preview_intersections[a+b*3] = false
		# placing single tile
		else:
			var is_empty
			var tile_resource = TileHandler.tiles[held_item.tile_id]
			if tile_resource.wall:
				is_empty = tile_grid.is_wall_empty(new_pos)
			else:
				is_empty = tile_grid.is_tile_empty(new_pos)
			if !is_empty:
				preview_intersections[0] = true
			else:
				preview_intersections[0] = false
	
	preview_sprite.update_intersections(preview_intersections)

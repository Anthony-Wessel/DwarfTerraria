class_name ItemUser
extends Node2D

static var instance : ItemUser

var held_item : Item
var tile_grid : GameWorld
#var miner : Miner
@export var inventory : Inventory

#@export var held_prefab : HeldItem

@export var preview_sprite : Node2D
var preview_intersections : Array[bool]
var prev_pos : Vector2i

var instantiated_use_scene : Node

func _init():
	HUD.instance.hotbar.on_selected_item_changed.connect(swap_item)
	instance = self

func _ready():
	tile_grid = GameWorld.instance
	#miner = Miner.instance
	for i in 9:
		preview_intersections.append(false)

func swap_item(new_item : Item):
	preview_sprite.clear()
	held_item = new_item
	
	if new_item == null:
		return
	
	if new_item is PlaceableItem:
		var tile_pos = Vector2i(tile_grid.get_local_mouse_position()/8)
		update_preview_sprite(tile_pos)
	
	#held_prefab.set_sprite(new_item.held_texture)
	#var weapon = new_item as WeaponItem
	#if weapon:
		#held_prefab.set_collision(weapon.collision_shape)

func _process(_delta):
	if held_item is PlaceableItem:
		var tile_pos = Vector2i(tile_grid.get_local_mouse_position()/GlobalReferences.TILE_SIZE)
		if tile_pos != prev_pos:
			update_preview_sprite(tile_pos)
			prev_pos = tile_pos
	
	if instantiated_use_scene == null and held_item != null:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			if held_item.get_use_scene() != null:
				instantiated_use_scene = held_item.get_use_scene().instantiate()
				add_child(instantiated_use_scene)
			else:
				push_error("Trying to use item that has no use scene set: ", held_item.name)
"""
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
"""

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
		
		var tile_resource = TileHandler.tiles[held_item.tile_ids[0]]
		var placing_wall = tile_resource.wall
		
		for a in held_item.size.x:
			for b in held_item.size.y:
				if !placing_wall and !tile_grid.is_tile_empty(new_pos + Vector2i(a,b)):
					preview_intersections[a+b*3] = true
				elif placing_wall and !tile_grid.is_wall_empty(new_pos + Vector2i(a,b)):
					preview_intersections[a+b*3] = true
				else:
					preview_intersections[a+b*3] = false
	
	preview_sprite.update_intersections(preview_intersections)

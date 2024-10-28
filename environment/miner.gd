class_name Miner
extends Node2D

var available_sprites = []
var used_sprites = {}

static var instance : Miner
@export var game_world : GameWorld

func _init():
	instance = self

func _ready():
	available_sprites = get_children()
	game_world = GameWorld.instance

func get_mined_tiles_count():
	var count = 0
	for coords in previously_mined_tiles:
		if previously_mined_tiles[coords] != -1:
			count += 1
	return count

var previously_mined_tiles : Dictionary
var previous_tool_wall := false
func mine_tile(coords_list : Array[Vector2i], _mining_tier, amount : float, wall : bool):
	# detect tool swap
	if previous_tool_wall != wall:
		previously_mined_tiles.clear()
		previous_tool_wall = wall
	
	# remove old tiles
	for coords in previously_mined_tiles.keys():
		if !coords_list.has(coords):
			previously_mined_tiles.erase(coords)
	
	# add new tiles
	for coords in coords_list:
		if !previously_mined_tiles.has(coords):
			previously_mined_tiles[coords] = 0
	
	for coords in previously_mined_tiles.keys():
		if game_world.is_tile_empty(coords, wall):
			previously_mined_tiles[coords] = -1
			continue
		
		var tile_resource = game_world.get_tile(coords, wall)
		if tile_resource == null:
			continue
		
		if previously_mined_tiles[coords] != -1:
			if _mining_tier >= tile_resource.hardness:
				previously_mined_tiles[coords] += amount/get_mined_tiles_count()
		
				# tile destroyed
				if previously_mined_tiles[coords] >= tile_resource.health:
					game_world.break_tile(coords, wall)
	
	update_sprites()

func update_sprites():
	# unallocated sprites from old tiles
	for coords in used_sprites.keys():
		if !previously_mined_tiles.has(coords):
			available_sprites.append(used_sprites[coords])
			used_sprites.erase(coords)
	
	
	for coords in previously_mined_tiles:
		if previously_mined_tiles[coords] == -1:
			continue
		
		# allocate sprites to new tiles
		if !used_sprites.has(coords):
			used_sprites[coords] = available_sprites[0]
			used_sprites[coords].position = coords * GlobalReferences.TILE_SIZE
			available_sprites.remove_at(0)
		
		# get the tile information
		var tile_resource := game_world.get_tile(coords, previous_tool_wall)
		
		# don't update sprite on empty tile
		if tile_resource.health == 0:
			used_sprites[coords].frame = 0
			continue
		
		# update tile break animation
		var progress = previously_mined_tiles[coords] / tile_resource.health
		var stepped_progress = floor(progress*3)
		used_sprites[coords].frame = stepped_progress
		

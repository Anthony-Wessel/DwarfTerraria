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

var previously_mined_tiles : Dictionary
var previous_tool_wall := false
func mine_tile(coords_list : Array[Vector2i], mining_tier, amount : float, wall : bool):
	var changed := false
	
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
		if wall and game_world.is_wall_empty(coords) or !wall and game_world.is_tile_empty(coords):
			previously_mined_tiles[coords] = -1
		else:
			previously_mined_tiles[coords] += amount/previously_mined_tiles.size()
		
		var tile_resource
		if wall: tile_resource = game_world.get_wall(coords)
		else : tile_resource = game_world.get_tile(coords)
		
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
		# allocate sprites to new tiles
		if !used_sprites.has(coords):
			used_sprites[coords] = available_sprites[0]
			used_sprites[coords].position = coords * GlobalReferences.TILE_SIZE
			available_sprites.remove_at(0)
		
		# get the tile information
		var tile_resource : TileResource
		if previous_tool_wall: tile_resource = game_world.get_wall(coords)
		else: tile_resource = game_world.get_tile(coords)
		
		# don't update sprite on empty tile
		if tile_resource.health == 0:
			used_sprites[coords].frame = 0
			continue
		
		# update tile break animation
		var progress = previously_mined_tiles[coords] / tile_resource.health
		var stepped_progress = floor(progress*3)
		used_sprites[coords].frame = stepped_progress
		
